#!/bin/bash
# ==============================================================================
# Helper to set up Global API Key & Email for flarectl
# ==============================================================================

EMAIL="darian.hickman@gmail.com"

if [ -z "$1" ]; then
  echo "======================================================================"
  echo "flarectl requires Cloudflare Global API Key authentication."
  echo ""
  echo "1. Visit: https://dash.cloudflare.com/profile/api-tokens"
  echo "2. Under 'API Keys', click 'View' next to 'Global API Key'"
  echo "3. Run:"
  echo "     ./get_api_key.sh <PASTE_GLOBAL_API_KEY_HERE>"
  echo "======================================================================"
  exit 0
fi

API_KEY="$1"

cat << ENVFILE > .env.cloudflare
export CF_API_KEY="$API_KEY"
export CF_API_EMAIL="$EMAIL"
export CLOUDFLARE_API_KEY="$API_KEY"
export CLOUDFLARE_EMAIL="$EMAIL"
ENVFILE

echo "✅ Saved credentials to .env.cloudflare"
source .env.cloudflare

echo "Testing flarectl with Global API Key..."
/Users/darianhickman/go/bin/flarectl zone list
