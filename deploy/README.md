# Isolated Aimeos preview — deployment draft

Source: Aimeos release 2026.04.1. No production services or data are used.
This is a draft: PHP/Composer/Docker are unavailable in the preparation environment,
so container build, artisan argument compatibility and live storefront/admin still
require verification before this can be called a working deployment.

Push this branch to an owned GitHub fork, then create a Render Blueprint from it.
Set DEMO_ADMIN_EMAIL and a unique DEMO_ADMIN_PASSWORD in Render, not in Git.
The Blueprint requests a free web service and a separate free PostgreSQL database.
Open `/` for the storefront and `/admin` for administration after startup succeeds.

Limitations:
- Free Postgres expires after 30 days; this is not a production database.
- Free compute hours and bandwidth/build allowances are shared with other services.
- Free web storage is ephemeral: sessions, uploaded media and demo images created at
  initialization may be lost on restart/spindown. Media persistence/restoration must
  be resolved before relying on the preview across restarts.
- This shows the stock storefront/admin; merchant onboarding and AI are not configured.
- Dependencies are resolved during build because upstream has no Composer lockfile.
  Retain and review the resolved lockfile before any production use.
- Initialization does not reset the DB; it uses an advisory lock and a DB marker.
  If initialization is interrupted, inspect the logs before retrying.
- Check both `/ready` and actual catalog/admin pages, static assets and login before
  sharing a successful preview URL. A health response alone is not sufficient.
