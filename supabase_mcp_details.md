# Supabase MCP Server Details

This document contains the configuration and usage instructions for the Supabase Model Context Protocol (MCP) server.

## Installation / Configuration

To connect Antigravity to the Supabase MCP server, add the following configuration to your `mcp_config.json` file.

### Configuration JSON
```json
{
  "mcpServers": {
    "supabase": {
      "serverUrl": "https://mcp.supabase.com/mcp"
    }
  }
}
```

- **Target config file path**: `C:\Users\JZ Original\.gemini\antigravity-ide\mcp_config.json`
- **Authentication**: After adding this configuration and restarting, you will be prompted to log in to Supabase via your browser to complete the OAuth flow.
- **Manual Authentication / Troubleshooting**: If you run into issues, open Agent Settings (`Ctrl+,` on Windows), navigate to the **Customizations** tab, and click the **Authenticate** button next to the Supabase server.

---

## Available Tools

### Database
- `list_tables` - List all tables in the database
- `list_extensions` - List available/installed Postgres extensions
- `list_migrations` - List database migrations
- `apply_migration` - Apply a database migration
- `execute_sql` - Execute SQL queries

### Debugging
- `get_logs` - Retrieve service logs (API, Postgres, Edge Functions, Auth, Storage, Realtime)
- `get_advisors` - Get security and performance advisors

### Development
- `get_project_url` - Get the API URL for a project
- `get_publishable_keys` - Get publishable and legacy anon API keys for a project
- `generate_typescript_types` - Generate TypeScript types from schema

### Edge Functions
- `list_edge_functions` - List all Edge Functions
- `get_edge_function` - Get a specific Edge Function
- `deploy_edge_function` - Deploy an Edge Function

### Account Management
- `list_projects` / `get_project` - List or get project details
- `create_project` / `pause_project` / `restore_project` - Manage projects
- `list_organizations` / `get_organization` - Organization management
- `get_cost` / `confirm_cost` - Cost information

### Docs
- `search_docs` - Search Supabase documentation

### Branching (Experimental)
- `create_branch` / `list_branches` / `delete_branch` - Branch management
- `merge_branch` / `reset_branch` / `rebase_branch` - Branch operations

### Storage (Disabled by default)
- `list_storage_buckets` - List storage buckets
- `get_storage_config` / `update_storage_config` - Storage configuration

---

## Configuration Options / Query Parameters

You can append query parameters to the URL to customize the server scope:
- `read_only=true`: Execute all queries as a read-only Postgres user.
  - Example: `https://mcp.supabase.com/mcp?read_only=true`
- `project_ref=<id>`: Scope the server to a specific project (disables account-level tools).
  - Example: `https://mcp.supabase.com/mcp?project_ref=abc123`
- `features=<groups>`: Enable only specific tool groups (comma-separated).
  - Example: `https://mcp.supabase.com/mcp?features=database,docs`
