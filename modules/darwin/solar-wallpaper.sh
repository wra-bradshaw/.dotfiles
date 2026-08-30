set -u

action=${1:?usage: solar-wallpaper-reconcile enable|disable HOME SOURCE_CATALOG PREFERENCES_DOMAIN JQ [FORCE_RESTART] [RESTART_ALLOWED]}
user_home=${2:?missing user home}
source_catalog=${3:?missing source catalog}
preferences_domain=${4:?missing preferences domain}
jq_bin=${5:?missing jq executable}
force_restart=${6:-0}
restart_allowed=${7:-1}

custom_dir="$user_home/Library/Application Support/com.apple.wallpaper/aerials/custom"
application_support_dir="$user_home/Library/Application Support"
library_dir="$user_home/Library"
catalog="$custom_dir/entries.json"
path_key=AerialManifestLocalPathOverride
force_key=AerialManifestForceLocal
changed=0
work_file=

cleanup_work_file() {
  if [ -n "$work_file" ]; then
    /bin/rm -f -- "$work_file"
  fi
}
trap cleanup_work_file EXIT HUP INT TERM

warning() {
  printf '%s\n' \
    '************************************************************************' \
    'WARNING: solarWallpaper could not use Apple'"'"'s wallpaper catalog.' \
    "$1" \
    'The local catalog and wallpaper preference overrides have been removed.' \
    'nix-darwin activation will continue.' \
    '************************************************************************' >&2
}

preference_exists() {
  /usr/bin/defaults read "$preferences_domain" "$1" >/dev/null 2>&1
}

delete_preference() {
  key=$1
  if preference_exists "$key"; then
    if /usr/bin/defaults delete "$preferences_domain" "$key"; then
      changed=1
    else
      printf 'warning: solarWallpaper could not delete preference %s\n' "$key" >&2
    fi
  fi
}

prune_created_directory() {
  directory=$1
  marker="$directory/.solarWallpaper-created"
  [ -f "$marker" ] || return 0

  /bin/rm -f -- "$marker"
  if ! /bin/rmdir "$directory" 2>/dev/null; then
    # Keep ownership information if unrelated contents prevent pruning.
    : > "$marker"
  fi
}

remove_managed_catalog() {
  # The exact entries.json path is this module's override location. Other
  # files in custom_dir are user/Apple state and are deliberately preserved.
  if [ -e "$catalog" ]; then
    /bin/rm -f -- "$catalog"
    changed=1
  fi
  # Clean up a stale ownership marker from an older version, if present.
  /bin/rm -f -- "$custom_dir/.solarWallpaper-managed"

  prune_created_directory "$custom_dir"
  prune_created_directory "${custom_dir%/custom}"
  prune_created_directory "${custom_dir%/aerials/custom}"
  prune_created_directory "$application_support_dir"
  prune_created_directory "$library_dir"
}

remove_overrides() {
  remove_managed_catalog
  delete_preference "$path_key"
  delete_preference "$force_key"
}

restart_wallpaper_processes() {
  if { [ "$changed" -eq 1 ] || [ "$force_restart" -eq 1 ]; } && [ "$restart_allowed" -eq 1 ]; then
    /usr/bin/killall WallpaperAgent WallpaperAerialsExtension 2>/dev/null || true
  fi
}

find_id_index() {
  array_path=$1
  wanted_id=$2
  file=$3
  i=0

  while /usr/bin/plutil -extract "$array_path.$i" json -o /dev/null "$file" 2>/dev/null; do
    current_id=$(/usr/bin/plutil -extract "$array_path.$i.id" raw -o - "$file" 2>/dev/null || true)
    if [ "$current_id" = "$wanted_id" ]; then
      printf '%s\n' "$i"
      return 0
    fi
    i=$((i + 1))
  done
  return 1
}

find_asset_index() {
  wanted_id=$1
  file=$2
  i=0

  while /usr/bin/plutil -extract "assets.$i" json -o /dev/null "$file" 2>/dev/null; do
    current_id=$(/usr/bin/plutil -extract "assets.$i.shotID" raw -o - "$file" 2>/dev/null || true)
    if [ "$current_id" = "$wanted_id" ]; then
      printf '%s\n' "$i"
      return 0
    fi
    i=$((i + 1))
  done
  return 1
}

enable_combining() {
  wanted_id=$1
  category_index=0

  while /usr/bin/plutil -extract "categories.$category_index" json -o /dev/null "$work_file" 2>/dev/null; do
    if subcategory_index=$(find_id_index "categories.$category_index.subcategories" "$wanted_id" "$work_file"); then
      key="categories.$category_index.subcategories.$subcategory_index.combineVariants"
      if /usr/bin/plutil -extract "$key" raw -o /dev/null "$work_file" 2>/dev/null; then
        /usr/bin/plutil -replace "$key" -bool true "$work_file" || return 1
      else
        /usr/bin/plutil -insert "$key" -bool true "$work_file" || return 1
      fi
      return 0
    fi
    category_index=$((category_index + 1))
  done

  printf 'missing collection ID %s\n' "$wanted_id" >&2
  return 1
}

set_solar_variant() {
  shot_id=$1
  altitude=$2
  azimuth=$3

  asset_index=$(find_asset_index "$shot_id" "$work_file") || {
    printf 'missing asset ID %s\n' "$shot_id" >&2
    return 1
  }

  key="assets.$asset_index.variant"
  value="{\"solar\":{\"altitude\":$altitude,\"azimuth\":$azimuth}}"
  if /usr/bin/plutil -extract "$key" json -o /dev/null "$work_file" 2>/dev/null; then
    solar_key="$key.solar"
    if /usr/bin/plutil -extract "$solar_key" json -o /dev/null "$work_file" 2>/dev/null; then
      /usr/bin/plutil -replace "$solar_key" -json "{\"altitude\":$altitude,\"azimuth\":$azimuth}" "$work_file" || return 1
    else
      /usr/bin/plutil -insert "$solar_key" -json "{\"altitude\":$altitude,\"azimuth\":$azimuth}" "$work_file" || return 1
    fi
  else
    /usr/bin/plutil -insert "$key" -json "$value" "$work_file" || return 1
  fi
}

ensure_managed_directory() {
  directory=$1
  if [ ! -d "$directory" ]; then
    /bin/mkdir "$directory" || return 1
    : > "$directory/.solarWallpaper-created"
  fi
}

install_catalog() {
  ensure_managed_directory "$library_dir" || return 1
  ensure_managed_directory "$application_support_dir" || return 1
  ensure_managed_directory "${custom_dir%/aerials/custom}" || return 1
  ensure_managed_directory "${custom_dir%/custom}" || return 1
  ensure_managed_directory "$custom_dir" || return 1

  if [ ! -f "$catalog" ] || ! /usr/bin/cmp -s "$work_file" "$catalog"; then
    staging="$custom_dir/.entries.json.solarWallpaper.$$"
    if ! /usr/bin/install -m 0644 "$work_file" "$staging"; then
      /bin/rm -f -- "$staging"
      return 1
    fi
    if ! /bin/mv -f -- "$staging" "$catalog"; then
      /bin/rm -f -- "$staging"
      return 1
    fi
    changed=1
  fi
}

set_preferences() {
  current_path=$(/usr/bin/defaults read "$preferences_domain" "$path_key" 2>/dev/null || true)
  if [ "$current_path" != "$catalog" ]; then
    /usr/bin/defaults write "$preferences_domain" "$path_key" -string "$catalog" || return 1
    changed=1
  fi

  current_force=$(/usr/bin/defaults read "$preferences_domain" "$force_key" 2>/dev/null || true)
  if [ "$current_force" != 1 ]; then
    /usr/bin/defaults write "$preferences_domain" "$force_key" -bool true || return 1
    changed=1
  fi
}

if [ "$action" = disable ]; then
  remove_overrides
  restart_wallpaper_processes
  exit 0
fi

if [ "$action" != enable ]; then
  printf 'unknown solarWallpaper action: %s\n' "$action" >&2
  exit 2
fi

if [ ! -f "$source_catalog" ] || ! /usr/bin/plutil -convert json -o /dev/null "$source_catalog" 2>/dev/null; then
  warning "Missing or invalid source catalog: $source_catalog"
  remove_overrides
  restart_wallpaper_processes
  exit 0
fi

work_file=$(/usr/bin/mktemp "${TMPDIR:-/tmp}/solar-wallpaper.XXXXXX") || exit 1
if ! /bin/cp "$source_catalog" "$work_file"; then
  warning "Could not copy source catalog: $source_catalog"
  remove_overrides
  restart_wallpaper_processes
  exit 0
fi

if ! enable_combining 0DC99DD8-3386-4D1E-8878-C43E97EB710A \
  || ! enable_combining 67512508-D33E-4CBC-8A9E-BE55CEE35C4C \
  || ! set_solar_variant TA_L_001 5 160 \
  || ! set_solar_variant TA_L_002 35 180 \
  || ! set_solar_variant TA_D_001 5 180 \
  || ! set_solar_variant TA_D_002 -35 140 \
  || ! set_solar_variant GG_A_SUNSET 5 160 \
  || ! set_solar_variant GG_A_DAY 35 180 \
  || ! set_solar_variant GG_A_EVENING 5 180 \
  || ! set_solar_variant GG_A_NIGHT -35 140 \
  || ! /usr/bin/plutil -convert json -o /dev/null "$work_file"; then
  warning 'The source catalog does not contain every expected Tahoe and Golden Gate entry.'
  remove_overrides
  restart_wallpaper_processes
  exit 0
fi

# plutil does not guarantee dictionary key order. Canonicalize the JSON so
# repeated activations compare semantic state instead of serializer order.
canonical_file=$(/usr/bin/mktemp "${TMPDIR:-/tmp}/solar-wallpaper-canonical.XXXXXX") || exit 1
if ! "$jq_bin" -S . "$work_file" > "$canonical_file"; then
  /bin/rm -f -- "$canonical_file"
  warning 'The generated wallpaper override is not valid JSON.'
  remove_overrides
  restart_wallpaper_processes
  exit 0
fi
/bin/mv -f -- "$canonical_file" "$work_file"

if ! install_catalog || ! set_preferences; then
  warning 'The generated wallpaper override could not be installed.'
  remove_overrides
fi
restart_wallpaper_processes
