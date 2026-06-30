-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: Mock provider auth.users + Realtime
-- Run this in your Supabase SQL editor (Dashboard → SQL Editor → New Query)
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Enable Realtime on messages table (fixes "Unable to subscribe" error)
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.bookings;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Create 8 real auth users for mock providers.
--    Password for all accounts: Herfa@2024
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
  pwd text := '$2a$10$PQZMzjHQl9GkEaZMnFy7/.MuNpHqW4yRbK7CcTsZYk0M2ZAGLaKqC';
BEGIN

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000001','ahmed.plumber@herfa-mock.com',pwd,now(),
    '{"full_name":"احمد محمد","phone":"01001234567","city":"القاهرة","role":"provider","skills":"سباكة","bio":"خبير في اصلاح تسريبات المياه وتركيب الادوات الصحية","hourly_rate":"120","experience_years":"8","latitude":"30.0444","longitude":"31.2357","avatar_url":"https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000002','mohamed.electric@herfa-mock.com',pwd,now(),
    '{"full_name":"محمد علي","phone":"01009876543","city":"الجيزة","role":"provider","skills":"كهرباء","bio":"كهربائي معتمد متخصص في التمديدات المنزلية","hourly_rate":"150","experience_years":"10","latitude":"30.0131","longitude":"31.2089","avatar_url":"https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000003','kareem.painter@herfa-mock.com',pwd,now(),
    '{"full_name":"كريم حسن","phone":"01112345678","city":"الاسكندرية","role":"provider","skills":"دهانات","bio":"دهان محترف للمنازل والشركات","hourly_rate":"90","experience_years":"6","latitude":"31.2001","longitude":"29.9187","avatar_url":"https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000004','tarek.ac@herfa-mock.com',pwd,now(),
    '{"full_name":"طارق ابراهيم","phone":"01223456789","city":"القاهرة","role":"provider","skills":"تكييف","bio":"فني تكييف وتبريد معتمد صيانة وتركيب جميع انواع التكييفات","hourly_rate":"130","experience_years":"7","latitude":"30.0566","longitude":"31.2394","avatar_url":"https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000005','samy.carpenter@herfa-mock.com',pwd,now(),
    '{"full_name":"سامي يوسف","phone":"01334567890","city":"القاهرة","role":"provider","skills":"نجارة","bio":"نجار حرفي متخصص في صناعة وتصليح الاثاث والابواب","hourly_rate":"100","experience_years":"12","latitude":"30.0320","longitude":"31.2241","avatar_url":"https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000006','omar.tiles@herfa-mock.com',pwd,now(),
    '{"full_name":"عمر فاروق","phone":"01445678901","city":"الجيزة","role":"provider","skills":"بلاط وسيراميك","bio":"فني تركيب بلاط وسيراميك للحمامات والمطابخ","hourly_rate":"110","experience_years":"9","latitude":"30.0254","longitude":"31.1993","avatar_url":"https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000007','hassan.cleaning@herfa-mock.com',pwd,now(),
    '{"full_name":"حسن رضا","phone":"01556789012","city":"القاهرة","role":"provider","skills":"تنظيف","bio":"تنظيف احترافي للمنازل والمكاتب","hourly_rate":"80","experience_years":"5","latitude":"30.0680","longitude":"31.2590","avatar_url":"https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, created_at, updated_at)
  VALUES ('a1000000-0000-0000-0000-000000000008','nader.maintenance@herfa-mock.com',pwd,now(),
    '{"full_name":"نادر صلاح","phone":"01667890123","city":"الاسكندرية","role":"provider","skills":"صيانة عامة","bio":"فني صيانة عامة للمنازل والشركات اصلاح جميع الاعطال","hourly_rate":"95","experience_years":"11","latitude":"31.2156","longitude":"29.9553","avatar_url":"https://images.unsplash.com/photo-1542909168-82c3e7fdca5c?w=200&q=80"}'::jsonb,
    'authenticated','authenticated',now(),now()) ON CONFLICT (id) DO NOTHING;

END $$;

-- 3. Mark all mock providers as approved so they show in searches
UPDATE public.providers SET is_approved = true, is_available = true
WHERE id IN (
  'a1000000-0000-0000-0000-000000000001',
  'a1000000-0000-0000-0000-000000000002',
  'a1000000-0000-0000-0000-000000000003',
  'a1000000-0000-0000-0000-000000000004',
  'a1000000-0000-0000-0000-000000000005',
  'a1000000-0000-0000-0000-000000000006',
  'a1000000-0000-0000-0000-000000000007',
  'a1000000-0000-0000-0000-000000000008'
);
