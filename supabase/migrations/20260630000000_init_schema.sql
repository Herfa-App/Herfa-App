-- Enable Earthdistance & Cube for rapid spatial query indexing
create extension if not exists cube;
create extension if not exists earthdistance;

-- 1. Profiles Table (Linked to auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  phone text,
  city text,
  role text check (role in ('customer', 'provider')),
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS for Profiles
alter table public.profiles enable row level security;

-- Row and Column Level Security (RLS + CLS)
create policy "Authenticated users can view non-PII profiles" on public.profiles
  for select using (auth.role() = 'authenticated');

create policy "Users can update their own profile." on public.profiles
  for update using (auth.uid() = id);

-- REVOKE direct phone select to prevent PII harvesting. Phone must be queried via RPC.
revoke select (phone) on public.profiles from public, anon, authenticated;

-- 2. Providers Table (1:1 link with Profiles)
create table public.providers (
  id uuid references public.profiles(id) on delete cascade primary key,
  skills text not null,
  bio text,
  experience_years integer default 0,
  hourly_rate numeric default 0,
  is_available boolean default true,
  is_approved boolean default false,
  rating numeric default 5.0,
  latitude double precision,
  longitude double precision
);

-- RLS for Providers
alter table public.providers enable row level security;

-- Allows anyone (including guest users) to read approved providers
create policy "Approved providers details viewable by everyone." on public.providers
  for select using (is_approved = true);

create policy "Providers can view their own unapproved details." on public.providers
  for select using (auth.uid() = id);

create policy "Providers can update their own details." on public.providers
  for update using (auth.uid() = id);

-- 3. Bookings Table (Referencing providers.id for schema-level integrity)
create table public.bookings (
  id uuid default gen_random_uuid() primary key,
  customer_id uuid references public.profiles(id) on delete cascade not null,
  provider_id uuid references public.providers(id) on delete cascade not null,
  status text check (status in ('pending', 'accepted', 'rejected', 'completed')) default 'pending',
  description text,
  booking_date timestamp with time zone not null,
  total_price numeric,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.bookings enable row level security;

create policy "Users can view bookings they are involved in." on public.bookings 
  for select using (auth.uid() = customer_id or auth.uid() = provider_id);

create policy "Customers can create bookings." on public.bookings 
  for insert with check (auth.uid() = customer_id);

-- Restrict direct updates of metadata except status.
create policy "Users can update their own bookings metadata except status." on public.bookings
  for update using (auth.uid() = customer_id)
  with check (auth.uid() = customer_id);

-- REVOKE direct status and total_price updates. Must go through designated RPCs.
revoke update (status, total_price) on public.bookings from public, anon, authenticated;

-- 4. Chat Messages Table with Database-Generated Conversation ID
create table public.messages (
  id uuid default gen_random_uuid() primary key,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  receiver_id uuid references public.profiles(id) on delete cascade not null,
  text text not null,
  type text check (type in ('text', 'image', 'voice')) default 'text',
  -- Enforces conversation sorting at DB-level. Client does not provide this.
  conversation_id text generated always as (
    least(sender_id::text, receiver_id::text) || '_' || greatest(sender_id::text, receiver_id::text)
  ) stored not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.messages enable row level security;

create policy "Users can view messages in their conversations." on public.messages 
  for select using (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy "Users can send messages." on public.messages 
  for insert with check (auth.uid() = sender_id);

-- 5. Trigger: Auto-create Profile & Provider on Auth Sign Up (Bulletproof cast safety)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  -- Create Profile
  insert into public.profiles (id, full_name, phone, city, role, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'User'),
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'city',
    coalesce(new.raw_user_meta_data->>'role', 'customer'),
    new.raw_user_meta_data->>'avatar_url'
  );

  -- If provider, create matching provider row (nullif protects against empty strings)
  if coalesce(new.raw_user_meta_data->>'role', 'customer') = 'provider' then
    insert into public.providers (id, skills, bio, experience_years, hourly_rate, latitude, longitude, is_approved)
    values (
      new.id,
      coalesce(new.raw_user_meta_data->>'skills', 'General'),
      coalesce(new.raw_user_meta_data->>'bio', ''),
      coalesce(nullif(new.raw_user_meta_data->>'experience_years', '')::integer, 0),
      coalesce(nullif(new.raw_user_meta_data->>'hourly_rate', '')::numeric, 0.0),
      coalesce(nullif(new.raw_user_meta_data->>'latitude', '')::double precision, 30.0444),
      coalesce(nullif(new.raw_user_meta_data->>'longitude', '')::double precision, 31.2357),
      false
    );
  end if;

  return new;
end;
$$ language plpgsql security definer set search_path = public, pg_temp;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 6. RPC: Secure Phone Retrieval (PII Exposer)
create or replace function public.get_contact_info(target_user_id uuid)
returns text as $$
declare
  phone_number text;
begin
  -- Expose phone ONLY if an accepted or completed booking exists between them OR own profile check
  if exists (
    select 1 from public.bookings 
    where ((customer_id = auth.uid() and provider_id = target_user_id)
       or (provider_id = auth.uid() and customer_id = target_user_id))
      and status in ('accepted', 'completed')
  ) or auth.uid() = target_user_id then
    select phone into phone_number from public.profiles where id = target_user_id;
    return phone_number;
  end if;
  
  return null;
end;
$$ language plpgsql security definer set search_path = public, pg_temp;

revoke execute on function public.get_contact_info(uuid) from public;
grant execute on function public.get_contact_info(uuid) to authenticated;

-- 7. RPC: Secure Booking Status Transitions
create or replace function public.update_booking_status(booking_id uuid, new_status text)
returns void as $$
declare
  b_cust uuid;
  b_prov uuid;
begin
  select customer_id, provider_id into b_cust, b_prov from public.bookings where id = booking_id;
  
  if new_status = 'accepted' or new_status = 'rejected' then
    if auth.uid() != b_prov then
      raise exception 'Only the provider can accept or reject bookings.';
    end if;
  elsif new_status = 'completed' then
    if auth.uid() != b_prov and auth.uid() != b_cust then
      raise exception 'Unauthorized to complete this booking.';
    end if;
  end if;

  update public.bookings set status = new_status where id = booking_id;
end;
$$ language plpgsql security definer set search_path = public, pg_temp;

revoke execute on function public.update_booking_status(uuid, text) from public;
grant execute on function public.update_booking_status(uuid, text) to authenticated;

-- 8. RPC: Provider Quote Pricing
create or replace function public.quote_booking_price(booking_id uuid, price numeric)
returns void as $$
declare
  b_prov uuid;
  b_status text;
begin
  select provider_id, status into b_prov, b_status from public.bookings where id = booking_id;
  
  if auth.uid() != b_prov then
    raise exception 'Only the assigned provider can quote a price.';
  end if;
  if b_status != 'pending' then
    raise exception 'Cannot quote price for a non-pending booking.';
  end if;

  update public.bookings set total_price = price where id = booking_id;
end;
$$ language plpgsql security definer set search_path = public, pg_temp;

revoke execute on function public.quote_booking_price(uuid, numeric) from public;
grant execute on function public.quote_booking_price(uuid, numeric) to authenticated;

-- 9. RPC: Geographic Distance Search (Uses GiST Earthdistance Index + Guest Browsing support)
-- Marked security definer to allow unauthenticated guest users to search approved provider cards
create or replace function public.get_nearby_providers(
  user_lat double precision,
  user_lng double precision,
  max_distance_km double precision default 50.0
)
returns table (
  id uuid,
  full_name text,
  city text,
  avatar_url text,
  skills text,
  bio text,
  experience_years integer,
  hourly_rate numeric,
  rating numeric,
  latitude double precision,
  longitude double precision,
  distance_km double precision
) as $$
begin
  return query
  select 
    p.id,
    prof.full_name,
    prof.city,
    prof.avatar_url,
    p.skills,
    p.bio,
    p.experience_years,
    p.hourly_rate,
    p.rating,
    p.latitude,
    p.longitude,
    -- Fast spatial calculations in km
    (earth_distance(ll_to_earth(user_lat, user_lng), ll_to_earth(p.latitude, p.longitude)) / 1000.0)::double precision as distance_km
  from public.providers p
  join public.profiles prof on p.id = prof.id
  where p.is_approved = true and p.is_available = true
    -- 1. GiST spatial pruning via Earthbox (superset bounding box search)
    and ll_to_earth(p.latitude, p.longitude) <@ earth_box(ll_to_earth(user_lat, user_lng), max_distance_km * 1000.0)
    -- 2. Precision pruning (cuts off the outer corners of the box to enforce exact radius circle)
    and earth_distance(ll_to_earth(user_lat, user_lng), ll_to_earth(p.latitude, p.longitude)) <= max_distance_km * 1000.0
  order by distance_km asc;
end;
$$ language plpgsql security definer set search_path = public, pg_temp stable;

-- 10. Indexes for Production Performance
create index idx_messages_conversation_id on public.messages(conversation_id);
create index idx_messages_created_at on public.messages(created_at desc);
create index idx_bookings_lookup on public.bookings(customer_id, provider_id, status);
-- GiST Index on location coordinate points (converts latitude & longitude to earth type)
create index idx_providers_geo on public.providers using gist (ll_to_earth(latitude, longitude));
