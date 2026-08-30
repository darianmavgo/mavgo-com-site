#!/bin/bash
# ============================================================
# CLOUDFLARE DEPLOYMENT SCRIPT — Mavgo.com Hugo Site
# Builds with Hugo, then deploys public/ to Cloudflare Pages
# Target: mavgo.com
# ============================================================

set -e

# Look for Cloudflare credentials in common locations
ENV_FILES=(
  "/Users/darianhickman/Documents/cloudflare_repo/secrets/.env"
  "/Users/darianhickman/Documents/Archive/Gen97/recruitment-worker/.env"
  "/Users/darianhickman/Documents/Gen97/recruitment-worker/.env"
)

for f in "${ENV_FILES[@]}"; do
  if [ -f "$f" ]; then
    TOKEN=$(grep -E "^(CLOUDFLARE_API_TOKEN|CF_API_TOKEN)=" "$f" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    if [ -n "$TOKEN" ]; then
      echo "📁 Loaded Cloudflare credentials from $f"
      export CLOUDFLARE_API_TOKEN="$TOKEN"
      break
    fi
  fi
done

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
  echo "❌ ERROR: CLOUDFLARE_API_TOKEN not found."
  exit 1
fi

PROJECT_NAME="mavgo-com"
DOMAIN="mavgo.com"

echo "🔨 Building Hugo site..."
hugo --minify

echo ""
echo "🚀 Deploying to Cloudflare Pages..."
npx wrangler pages deploy public/ --project-name "$PROJECT_NAME"

echo ""
echo "============================================================"
echo "✅ Deployment complete!"
echo "   Live at → https://$DOMAIN"
echo "============================================================"
