#!/usr/bin/env bash
# ============================================================================
# sync.sh — refresh the mechanical fields in data/projects/*.yaml from GitHub
# ============================================================================
# Each project page is generated from data/projects/<slug>.yaml. Most of that
# file is editorial (category, hero copy, feature cards, quickstart, related
# links) and is NEVER touched here. This script only re-derives the handful of
# fields that mirror the GitHub repo, and reports drift on everything else so
# you can decide what to hand-edit.
#
# Auto-written when changed:   visibility
# Reported only (never written): language (GitHub's byte-count guess is often
#                                wrong for installer/generated files), stars,
#                                last push, license, homepage, archived, fork
#
# Usage:
#   ./sync.sh                 apply safe updates + print a drift report
#   ./sync.sh --check         report only, write nothing; exit 1 if drift found
#   ./sync.sh --scaffold NAME create data/projects/NAME.yaml + content stub
#
# Requires: gh (authenticated — `gh auth status`), python3 (stdlib only).
# ============================================================================
set -euo pipefail

cd "$(dirname "$0")"

OWNER="darianmavgo"
DATA_DIR="data/projects"
CONTENT_DIR="content/projects"
MODE="${1:-apply}"

command -v gh >/dev/null || { echo "❌ gh CLI not found"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "❌ gh not authenticated — run: gh auth login"; exit 1; }

# jget <json> <dotted.path> — print a field from a JSON blob using python stdlib
JGET_PY='
import json, sys
key = sys.argv[1]
try:
    d = json.load(sys.stdin)
except Exception:
    print(""); sys.exit(0)
for part in key.split("."):
    d = d.get(part) if isinstance(d, dict) else None
    if d is None:
        break
if isinstance(d, bool):
    print("true" if d else "false")
else:
    print("" if d is None else d)
'
jget() { python3 -c "$JGET_PY" "$2" <<<"$1"; }

yval() { sed -n "s/^$2: *//p" "$1" | head -1; }

set_field() { # <file> <field> <new-value>
  local f="$1" field="$2" val="$3" cur
  cur="$(yval "$f" "$field")"
  [ "$cur" = "$val" ] && return 0
  if [ "$MODE" = "--check" ]; then
    echo "   ~ $field: '$cur' -> '$val'   (run ./sync.sh to apply)"
    DRIFT=1
  else
    sed -i '' -E "s|^$field:.*|$field: $val|" "$f"
    echo "   ✔ $field: '$cur' -> '$val'"
  fi
}

# ---------------------------------------------------------------------------
# --scaffold NAME
# ---------------------------------------------------------------------------
if [ "$MODE" = "--scaffold" ]; then
  NAME="${2:-}"
  [ -n "$NAME" ] || { echo "usage: ./sync.sh --scaffold <repo-name>"; exit 1; }
  YAML="$DATA_DIR/$NAME.yaml"
  MD="$CONTENT_DIR/$NAME.md"
  [ -e "$YAML" ] && { echo "❌ $YAML already exists"; exit 1; }

  J="$(gh repo view "$OWNER/$NAME" --json name,description,primaryLanguage,visibility,homepageUrl,licenseInfo 2>/dev/null)" \
    || { echo "❌ repo $OWNER/$NAME not found"; exit 1; }
  DESC="$(jget "$J" description)"
  LANG="$(jget "$J" primaryLanguage.name)"
  VIS="$(jget "$J" visibility | tr '[:upper:]' '[:lower:]')"
  HP="$(jget "$J" homepageUrl)"

  {
    echo "name: $NAME"
    echo "title: $NAME — TODO short title"
    echo "tagline: ${DESC:-TODO one-line description}"
    echo "category: data        # one of: data quant cloud games research"
    echo "language: ${LANG:-TODO}"
    echo "visibility: ${VIS:-public}"
    echo "github: https://github.com/$OWNER/$NAME"
    echo "badge_language: ${LANG:-TODO}"
    echo "badge_license: Open Source"
    echo "hero_eyebrow: TODO"
    echo "hero_description: ${DESC:-TODO paragraph}"
    [ -n "$HP" ] && echo "demo_url: $HP"
    echo "features:"
    echo "- icon: 🚀"
    echo "  title: TODO"
    echo "  body: TODO"
    echo "quickstart:"
    echo "- label: Install"
    echo "  code: TODO"
    echo "related:"
    echo "- mksqlite"
  } > "$YAML"

  printf -- '---\ntitle: "%s"\nlayout: project\ndataKey: "%s"\n---\n' "$NAME" "$NAME" > "$MD"
  echo "✔ wrote $YAML"
  echo "✔ wrote $MD"
  echo "→ edit category / hero_eyebrow / features / quickstart before deploying"
  exit 0
fi

# ---------------------------------------------------------------------------
# apply / --check : walk every project
# ---------------------------------------------------------------------------
DRIFT=0
NOW_TS=$(date +%s)

for f in "$DATA_DIR"/*.yaml; do
  slug="$(basename "$f" .yaml)"
  repo="$(sed -n 's#^github: https://github.com/##p' "$f" | head -1)"
  [ -n "$repo" ] || { echo "• $slug — no github: url, skipped"; continue; }

  J="$(gh repo view "$repo" --json description,primaryLanguage,visibility,stargazerCount,pushedAt,licenseInfo,homepageUrl,isArchived,isFork 2>/dev/null)" || {
    echo "• $slug — ⚠️  $repo not found (renamed or deleted?)"
    DRIFT=1
    continue
  }

  gh_desc="$(jget "$J" description)"
  gh_lang="$(jget "$J" primaryLanguage.name)"
  gh_vis="$(jget "$J" visibility | tr '[:upper:]' '[:lower:]')"
  gh_stars="$(jget "$J" stargazerCount)"
  gh_push="$(jget "$J" pushedAt)"
  gh_lic="$(jget "$J" licenseInfo.spdxId)"
  gh_home="$(jget "$J" homepageUrl)"
  gh_arch="$(jget "$J" isArchived)"
  gh_fork="$(jget "$J" isFork)"

  echo "• $slug ($repo)"

  # --- auto-writable field: visibility is unambiguous ---
  [ -n "$gh_vis" ] && set_field "$f" visibility "$gh_vis"

  # --- report-only drift ---
  cur_lang="$(yval "$f" language)"
  if [ -n "$gh_lang" ] && [ "$gh_lang" != "$cur_lang" ]; then
    echo "   i GitHub primary language is '$gh_lang' (yaml says '$cur_lang' — edit if wrong)"
  fi
  cur_demo="$(yval "$f" demo_url)"
  if [ -n "$gh_home" ] && [ "$gh_home" != "$cur_demo" ]; then
    echo "   i homepage on GitHub: $gh_home  (add 'demo_url:' to show a Live Demo button)"
  fi
  [ "$gh_arch" = "true" ] && echo "   i repo is ARCHIVED on GitHub"
  [ "$gh_fork" = "true" ] && echo "   i repo is a FORK on GitHub"
  if [ -n "$gh_push" ]; then
    push_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$gh_push" +%s 2>/dev/null || echo "$NOW_TS")
    days=$(( (NOW_TS - push_ts) / 86400 ))
    [ "$days" -gt 365 ] && echo "   i last push ${days}d ago (${gh_push%%T*})"
  fi
  echo "   · stars:$gh_stars  license:${gh_lic:-none}  desc:\"${gh_desc:0:70}\""
done

echo
if [ "$MODE" = "--check" ] && [ "$DRIFT" -ne 0 ]; then
  echo "drift detected — run ./sync.sh to apply the safe updates"
  exit 1
fi

# ---------------------------------------------------------------------------
# new repos with no project file yet
# ---------------------------------------------------------------------------
echo "Public source repos with no data/projects/*.yaml:"
gh repo list "$OWNER" --source --no-archived -L 300 \
  --json name,visibility,isFork \
  --jq '.[] | select(.isFork|not) | select(.visibility=="public") | .name' \
  | while read -r name; do
      [ -f "$DATA_DIR/$name.yaml" ] || echo "   + $name   (./sync.sh --scaffold $name)"
    done
echo "done."
