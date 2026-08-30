#!/bin/bash
# ==============================================================================
# update_www_dns.sh
# Uses flarectl to point www.mavgo.com to the Cloudflare Pages deployment
# ==============================================================================

if [ -z "$CF_API_KEY" ] || [ -z "$CF_API_EMAIL" ]; then
  if [ -f ".env.cloudflare" ]; then
    source .env.cloudflare
  fi
fi

if [ -z "$CF_API_KEY" ] && [ -z "$CF_API_TOKEN" ]; then
  echo "❌ Missing Cloudflare credentials."
  echo "Please set CF_API_KEY + CF_API_EMAIL or CF_API_TOKEN."
  exit 1
fi

echo "🔄 Updating DNS for www.mavgo.com using flarectl..."

/Users/darianhickman/go/bin/flarectl dns create-or-update \
  --zone "mavgo.com" \
  --name "www" \
  --type "CNAME" \
  --content "mavgo-com.pages.dev" \
  --proxy
