#!/bin/bash
# ==============================================================================
# link_mavgo_domains.sh
# Adds mavgo.com and www.mavgo.com as custom domains to the mavgo-com Pages project
# ==============================================================================

set -e

ACCOUNT_ID="d8dc30936fb37cbd74552d31a709f6cf"
PROJECT_NAME="mavgo-com"
TOKEN=$(grep -E 'oauth_token\s*=\s*' "$HOME/.wrangler/config/default.toml" | sed -E 's/.*oauth_token\s*=\s*"([^"]+)".*/\1/' | head -n 1)

echo "🔗 Attaching custom domains to Cloudflare Pages ($PROJECT_NAME)..."

for DOMAIN in "mavgo.com" "www.mavgo.com"; do
  echo "👉 Adding $DOMAIN..."
  curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/pages/projects/${PROJECT_NAME}/domains" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"name\":\"${DOMAIN}\"}" | grep -o '"success":[a-z]*' || true
done

echo ""
echo "✅ Done! Cloudflare is configuring SSL and DNS routing."
