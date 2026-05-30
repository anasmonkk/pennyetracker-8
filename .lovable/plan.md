## What to build

A new "External Tracking Sites" manager in `/admin/settings`, plus a new "Orders" card on the landing page (admin-only) that lists the configured sites.

### Data

New table `public.external_tracking_sites`:
- `id uuid`, `name text`, `website_url text`, `api_key text`, `test_endpoint_url text` (nullable), `auth_header_name text` default `'Authorization'`, `auth_header_prefix text` default `'Bearer '`, `description text` (nullable), `created_at`, `updated_at`, `created_by uuid`.
- RLS: admin-only for select/insert/update/delete (uses existing `is_admin(auth.uid())`). No `anon`/`authenticated` read — so the API keys never leak.
- GRANTs: `authenticated` (CRUD), `service_role` (ALL). No anon grant.

### `/admin/settings` — new card "External tracking sites"

- List of saved sites with name, URL link, masked key (`••••1234`), test endpoint.
- "Add site" dialog with fields: Name, Website URL, API key, Test endpoint URL (optional — defaults to website URL), Auth header name (default `Authorization`), Auth header prefix (default `Bearer `), Description.
- Per-row actions: **Test**, **Edit**, **Delete**.
- **Test** button: client-side `fetch(test_endpoint_url ?? website_url, { headers: { [auth_header_name]: prefix + api_key } })`. Shows toast with status code + ok/fail. Note: subject to CORS on the target — if it fails with a network error we'll show "Network/CORS error — key not verifiable from browser".

### Landing page — new "Orders" card

- Add a 6th feature card titled **Orders** (icon: `Package`) shown only when `isAdmin === true`.
- Card opens a route `/orders` (new) that lists all configured external tracking sites as clickable tiles (name, description, "Open site" → opens `website_url` in new tab). API keys are NOT displayed here, only on settings.
- Card is filtered out of the `features` array for non-admins (non-admins are already redirected away from landing anyway, but we gate it for safety).

## Files

- Migration: create table + RLS + grants.
- `src/routes/admin.settings.tsx` — add `<ExternalSitesCard />` component below the existing cards.
- `src/routes/orders.index.tsx` (new) — admin-only list view of sites.
- `src/routes/landing.tsx` — append "Orders" feature (admin-only), import `Package` icon.

## Out of scope

- Server-side key storage / secrets.
- Order ingestion from those external APIs (this only stores credentials + lets you open the sites).
