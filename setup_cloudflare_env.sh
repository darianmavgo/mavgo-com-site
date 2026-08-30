#!/bin/bash
# ==============================================================================
# setup_cloudflare_env.sh
# Extract OAuth token from Wrangler session and configure environment for flarectl
# ==============================================================================

set -e

WRANGLER_CONFIG="$HOME/.wrangler/config/default.toml"

if [ ! -f "$WRANGLER_CONFIG" ]; then
  echo "⚠️ Wrangler config not found at $WRANGLER_CONFIG"
  echo "👉 Running wrangler login..."
  npx wrangler login
fi

# Extract OAuth token from wrangler's default.toml
OAUTH_TOKEN=$(grep -E 'oauth_token\s*=\s*' "$WRANGLER_CONFIG" | sed -E 's/.*oauth_token\s*=\s*"([^"]+)".*/\1/' | head -n 1)

if [ -n "$OAUTH_TOKEN" ]; then
  echo "✅ Found active Wrangler OAuth token!"
  export CF_API_TOKEN="$OAUTH_TOKEN"
  export CLOUDFLARE_API_TOKEN="$OAUTH_TOKEN"
  
  # Also write to local .env for convenience
  echo "CF_API_TOKEN=$OAUTH_TOKEN" > .env.cloudflare
  echo "CLOUDFLARE_API_TOKEN=$OAUTH_TOKEN" >> .env.cloudflare
  echo "CF_API_EMAIL=darian.hickman@gmail.com" >> .env.cloudflare
  
  echo "📁 Saved credentials to .env.cloudflare"
  echo ""
  echo "To load into your current shell session, run:"
  echo "  source .env.cloudflare"
  echo ""
  echo "Testing flarectl connection with token..."
  if /Users/darianhickman/go/bin/flarectl zone list; then
    echo "🎉 flarectl is successfully connected via token!"
  else
    echo "ℹ️  If flarectl requires Global API Key, you can get it at: https://dash.cloudflare.com/profile/api-tokens"
  fi
else
  echo "❌ Could not find active oauth_token in $WRANGLER_CONFIG"
  echo "Please run: npx wrangler login"
  exit 1
fi
