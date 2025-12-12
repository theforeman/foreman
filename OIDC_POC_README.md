# Native OpenID Connect Support - Proof of Concept

## Overview

This Proof of Concept implements native OpenID Connect (OIDC) authentication in Foreman, eliminating the dependency on Apache's `mod_auth_openidc`. This implementation was developed with assistance from AI (Claude/Cursor).

## Key Features

### 1. **Multiple OIDC Providers**
- Support for multiple OIDC identity providers simultaneously
- Each provider is configured as an `AuthSourceOidc` record
- Users can choose which provider to authenticate with from the login page

### 2. **Native Application Authentication**
- OIDC logic entirely within the Rails application
- No dependency on Apache or external web server modules

### 3. **Vendor Agnostic**
- Should work with any OIDC-compliant provider.

### 4. **Automatic Discovery**
- Uses OIDC Discovery (.well-known/openid-configuration) by default
- Discovery happens automatically at authentication time
- Manual endpoint configuration available for IdPs without discovery support

### 5. **Secure Token Validation**
- JWT signature verification using JWKS
- Audience (aud) claim validation
- Issuer (iss) claim validation
- Nonce and state validation for replay protection
- Single trust boundary (application layer only)

### 6. **Flexible User Provisioning**
- Auto-provision users on first login (per provider)
- Link existing users by email (per provider)
- Configurable role mapping from IdP groups (per provider)

### 7. **Full API & UI Support**
- RESTful API for CRUD operations on OIDC providers
- Web UI for managing OIDC providers (Administer → Authentication Sources)
- Connection testing via API

## Architecture

### Components Created

```
app/
├── controllers/
│   ├── users_controller.rb                    # OIDC authentication callbacks and login
│   ├── auth_source_oidcs_controller.rb        # UI CRUD for OIDC providers
│   ├── concerns/
│   │   └── foreman/controller/parameters/
│   │       └── auth_source_oidc.rb            # Strong parameters
│   └── api/
│       └── v2/
│           └── auth_source_oidcs_controller.rb  # API CRUD for OIDC providers
├── models/
│   ├── auth_sources/
│   │   └── auth_source_oidc.rb                # OIDC Auth Source model
│   └── concerns/
│       └── user_oidc.rb                       # User model extensions for OIDC
├── helpers/
│   ├── auth_source_oidc_helper.rb             # UI helpers
│   ├── auth_sources_helper.rb                 # Extended for OIDC
│   └── login_helper.rb                        # OIDC providers on login page
└── views/
    ├── auth_source_oidcs/
    │   ├── new.html.erb
    │   ├── edit.html.erb
    │   ├── _form.html.erb
    │   └── _oidc_card_kebab.html.erb
    ├── auth_sources/
    │   ├── index.html.erb                     # Extended with "Create OIDC Source" button
    │   └── _auth_source_card.html.erb         # Extended for OIDC cards
    └── api/v2/auth_source_oidcs/
        ├── index.json.rabl
        ├── show.json.rabl
        ├── main.json.rabl
        ├── create.json.rabl
        └── update.json.rabl

config/
├── initializers/
│   └── omniauth.rb                            # OmniAuth configuration
└── routes/
    └── api/
        └── v2.rb                              # API v2 routes

db/
└── migrate/
    ├── 20251209124615_add_oidc_columns_to_auth_sources.rb
    └── 20251209125851_add_oidc_fields_to_users.rb

webpack/
└── assets/javascripts/react_app/components/
    └── LoginPage/
        ├── LoginPage.js                       # Extended with OIDC provider buttons
        └── LoginPage.scss                     # OIDC button styles
```

### Authentication Flow

```
1. User visits login page (/)
   ↓
2. User clicks "Login with <Provider>" button (POST to /users/auth/oidc_<id>)
   ↓
3. OmniAuth redirects to IdP authorization endpoint
   ↓
4. User authenticates at IdP
   ↓
5. IdP redirects back to Foreman callback (/users/auth/oidc_<id>/callback)
   ↓
6. OmniAuth exchanges authorization code for tokens
   ↓
7. Foreman validates ID Token (signature, claims, etc.)
   ↓
8. User.from_omniauth finds or creates user
   ↓
9. Session established, user logged in
```

## Discovery vs Manual Endpoints

### Automatic Discovery (Default)

By default, Foreman uses OIDC Discovery to automatically fetch endpoint URLs from the IdP's `.well-known/openid-configuration` document at authentication time. This is the recommended approach because:

- **Safer**: IdPs can change their endpoints; discovery ensures you always use current values
- **Simpler**: No need to manually configure endpoint URLs
- **Standard**: Most OIDC providers support discovery

Just configure the **Issuer URL** and credentials - endpoints are fetched automatically.

### Manual Endpoints (Fallback)

Some older or non-standard IdPs don't support the discovery endpoint. For these providers, you can manually configure all required endpoints:

- Authorization Endpoint
- Token Endpoint
- JWKS URI
- UserInfo Endpoint (optional)
- End Session Endpoint (optional)

**Important**: If all three required endpoints (authorization, token, jwks_uri) are configured, Foreman will use them instead of discovery. Leave them blank to use automatic discovery.

## Database Schema

### AuthSourceOidc Fields (added to auth_sources table)

| Field | Type | Description |
|-------|------|-------------|
| oidc_issuer | string | OIDC Issuer URL (must be HTTPS) |
| oidc_client_id | string | Client ID |
| oidc_client_secret | text (encrypted) | Client Secret |
| oidc_scopes | string | Scopes (default: "openid email profile") |
| oidc_redirect_uri | string | Callback URL (auto-generated from foreman_url) |
| oidc_authorization_endpoint | string | Authorization endpoint (only for non-discovery IdPs) |
| oidc_token_endpoint | string | Token endpoint (only for non-discovery IdPs) |
| oidc_userinfo_endpoint | string | UserInfo endpoint (only for non-discovery IdPs) |
| oidc_jwks_uri | string | JWKS URI (only for non-discovery IdPs) |
| oidc_end_session_endpoint | string | Logout endpoint (optional) |
| oidc_auto_provision | boolean | Auto-create users (default: false) |
| oidc_email_autolink | boolean | Link users by email (default: false) |
| oidc_groups_claim | string | Groups claim name (default: "groups") |
| oidc_role_mappings | text | YAML role mappings |

### User Model Extensions

| Field | Type | Description |
|-------|------|-------------|
| oidc_subject | string | OIDC subject identifier (sub claim) |
| oidc_issuer | string | OIDC issuer that authenticated this user |
| oidc_email | string | Email from OIDC |
| oidc_provider | string | Provider name (oidc_<id>) |

## Web UI

### Managing OIDC Providers

1. Navigate to **Administer → Authentication Sources**
2. Click **Create OIDC Source**
3. Fill in the required fields:
   - **Name**: Descriptive name (e.g., "Google", "Keycloak")
   - **Issuer URL**: OIDC issuer URL (must be HTTPS)
   - **Client ID**: From your IdP
   - **Client Secret**: From your IdP
4. (Optional) Configure manual endpoints if your IdP doesn't support discovery
5. Configure options in the **Options** tab:
   - Auto-provision users
   - Link by email
   - Groups claim
6. Submit the form
7. **Restart Foreman** to activate the new provider

### Login Page

Once OIDC providers are configured and Foreman is restarted:
- The login page will show "Login with <Provider>" buttons
- Clicking a button initiates OIDC authentication via POST request
- After successful authentication, the user is logged in

## API Reference

### List OIDC Providers
```bash
GET /api/v2/auth_source_oidcs

curl -u admin:password http://foreman.example.com/api/v2/auth_source_oidcs
```

### Show OIDC Provider
```bash
GET /api/v2/auth_source_oidcs/:id

curl -u admin:password http://foreman.example.com/api/v2/auth_source_oidcs/1
```

### Create OIDC Provider
```bash
POST /api/v2/auth_source_oidcs

# Standard provider (uses automatic discovery)
curl -u admin:password \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "auth_source_oidc": {
      "name": "Google",
      "oidc_issuer": "https://accounts.google.com",
      "oidc_client_id": "your-client-id",
      "oidc_client_secret": "your-client-secret",
      "oidc_auto_provision": true,
      "oidc_email_autolink": true
    }
  }' \
  http://foreman.example.com/api/v2/auth_source_oidcs

# Provider without discovery support (manual endpoints)
curl -u admin:password \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "auth_source_oidc": {
      "name": "Legacy IdP",
      "oidc_issuer": "https://legacy-idp.example.com",
      "oidc_client_id": "your-client-id",
      "oidc_client_secret": "your-client-secret",
      "oidc_authorization_endpoint": "https://legacy-idp.example.com/authorize",
      "oidc_token_endpoint": "https://legacy-idp.example.com/token",
      "oidc_jwks_uri": "https://legacy-idp.example.com/jwks",
      "oidc_userinfo_endpoint": "https://legacy-idp.example.com/userinfo"
    }
  }' \
  http://foreman.example.com/api/v2/auth_source_oidcs
```

### Update OIDC Provider
```bash
PUT /api/v2/auth_source_oidcs/:id

curl -u admin:password \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{
    "auth_source_oidc": {
      "oidc_auto_provision": false
    }
  }' \
  http://foreman.example.com/api/v2/auth_source_oidcs/1
```

Note: If `oidc_client_secret` is omitted or blank in an update, the existing secret is preserved.

### Delete OIDC Provider
```bash
DELETE /api/v2/auth_source_oidcs/:id

curl -u admin:password -X DELETE http://foreman.example.com/api/v2/auth_source_oidcs/1
```

### Check Configuration Status
Returns the current configuration status and whether discovery or manual endpoints are being used:
```bash
GET /api/v2/auth_source_oidcs/:id/status

curl -u admin:password http://foreman.example.com/api/v2/auth_source_oidcs/1/status
```

### Test Connection
Tests connectivity to the OIDC provider by fetching the discovery document:
```bash
GET /api/v2/auth_source_oidcs/:id/test_connection

curl -u admin:password http://foreman.example.com/api/v2/auth_source_oidcs/1/test_connection
```

## Testing


1. Navigate to the Foreman login page
2. Click "Login with <Provider>" button
3. Authenticate at the IdP
4. You should be redirected back and logged in

## Troubleshooting

### "No OIDC providers configured"
Create an OIDC provider via the API or UI.

### "OIDC provider configured but not properly initialized"
Restart Foreman after creating/modifying OIDC providers. OmniAuth configures providers at boot time.

### "Discovery not available"
If the `/test_connection` endpoint reports discovery is not available:
- The IdP may not support the `.well-known/openid-configuration` endpoint
- Configure manual endpoints (authorization, token, jwks_uri) for this provider

### CSRF Errors / "Invalid state parameter"
- Ensure cookies are enabled in the browser
- Check that the session is properly maintained between request and callback
- Verify the redirect URI matches exactly what's configured in the IdP
- The application uses `SameSite=Lax` cookies to allow cross-site redirects from IdPs

### SSL Errors
- The OIDC provider must be accessible over HTTPS
- Ensure SSL certificates are valid and trusted
- Self-signed certificates may cause issues

### "User already exists" errors
If a user with the same email or OIDC subject already exists:
- Enable `oidc_email_autolink` to automatically link existing users by email
- Manually update the existing user's `oidc_subject` and `oidc_issuer` fields

### Redirect URI Mismatch
- Check the `redirect_uri` field in the auth source (via API status endpoint or UI)
- Ensure it matches exactly what's configured in your IdP
- The redirect URI is auto-generated based on `Setting[:foreman_url]`

## Important Notes

1. **Restart Required**: After adding or modifying OIDC providers, you must restart Foreman for changes to take effect. OmniAuth providers are configured at boot time.

2. **HTTPS Required**: The `omniauth_openid_connect` gem requires HTTPS for OIDC providers. Self-signed certificates may cause issues.

3. **Redirect URIs**: The redirect URI format is `/users/auth/oidc_<id>/callback` where `<id>` is the database ID of the AuthSourceOidc record. The redirect URI is auto-generated from `Setting[:foreman_url]` when the auth source is created.

4. **Provider Names**: Each provider gets a unique name in the format `oidc_<id>` (e.g., `oidc_1`, `oidc_2`).

5. **Client Secret on Update**: When updating an auth source, if `oidc_client_secret` is left blank, the existing secret is preserved.

6. **POST-only Login**: Login initiation uses POST requests (not GET) for security - this prevents CSRF attacks via malicious links.

7. **Discovery vs Manual**: Discovery is used by default and is recommended. Only configure manual endpoints if your IdP doesn't support the `.well-known/openid-configuration` endpoint.

## Dependencies

The following gems are required (add to Gemfile):

```ruby
# Native OIDC support
gem 'omniauth', '~> 2.1'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
```

## Implemented Features

- [x] Multiple OIDC providers support
- [x] API for managing OIDC providers (CRUD + status + test)
- [x] UI for managing OIDC providers
- [x] OIDC provider buttons on login page
- [x] Automatic OIDC discovery (default)
- [x] Manual endpoint configuration (fallback for non-discovery IdPs)
- [x] User auto-provisioning
- [x] User linking by email
- [x] Secure token validation
- [x] POST-only login initiation (CSRF protection)

## TODO

- [ ] Configure permissions needed to manipulate AuthSourceOidc
- [ ] OIDC Authentication via API/hammer
- [ ] Update of redirect uri when the foreman url setting changes.
- [ ] RP-Initiated Logout support (single sign-out)
- [ ] Token refresh handling
- [ ] Group sync/mapping automation
- [ ] Import/export of OIDC configurations
- [ ] Migration from Apache mod_auth_openidc
