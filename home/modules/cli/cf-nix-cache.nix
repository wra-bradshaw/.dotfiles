{
  config,
  lib,
  pkgs,
  ...
}:
let
  configDir = "${config.xdg.configHome}/cf-nix-cache";
  secretspecFile = ../../../secretspec.toml;

  configFilter = ''
    {endpoint: .CF_NIX_CACHE_ENDPOINT, token: .CF_NIX_CACHE_TOKEN} | select(.endpoint and .token)
  '';
  nixConfigFilter = ''
    select(.CF_NIX_CACHE_ENDPOINT and .CF_NIX_CACHE_PUBLIC_KEY)
    | "extra-substituters = \(.CF_NIX_CACHE_ENDPOINT | sub("/$"; ""))/cache/will\nextra-trusted-public-keys = \(.CF_NIX_CACHE_PUBLIC_KEY)"
  '';
  netrcFilter = ''
    select(.CF_NIX_CACHE_ENDPOINT and .CF_NIX_CACHE_PULL_TOKEN)
    | "machine \(.CF_NIX_CACHE_ENDPOINT | sub("^https?://"; "") | sub("/.*$"; "")) login token password \(.CF_NIX_CACHE_PULL_TOKEN)"
  '';
in
{
  programs.secretspec = {
    enable = true;
    settings.defaults.providers.op = "onepassword://Personal";
  };
  home.packages = [ pkgs.cf-nix-cache ];

  home.activation.cfNixCacheConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    config_dir=${lib.escapeShellArg configDir}
    if [[ -v DRY_RUN ]]; then
      echo "would write config.json, nix.conf and netrc in $config_dir from secretspec"
    else
      mkdir -p "$config_dir"
      [ -e "$config_dir/netrc" ] || install -m 600 /dev/null "$config_dir/netrc"

      render_cf_nix_cache() {
        local target="$config_dir/$1" tmp
        tmp="$(mktemp "$target.XXXXXX")"
        if printf '%s' "$secrets" | ${lib.getExe pkgs.jq} -er "$2" > "$tmp"; then
          mv "$tmp" "$target"
        else
          rm -f "$tmp"
          echo "warning: secretspec returned incomplete cf-nix-cache secrets; leaving $target unchanged" >&2
        fi
      }

      if secrets=$(PATH="/usr/local/bin:/run/wrappers/bin:$PATH" ${lib.getExe config.programs.secretspec.package} --file ${secretspecFile} --reason "home-manager activation" export --format json); then
        render_cf_nix_cache config.json ${lib.escapeShellArg configFilter}
        render_cf_nix_cache nix.conf ${lib.escapeShellArg nixConfigFilter}
        render_cf_nix_cache netrc ${lib.escapeShellArg netrcFilter}
      else
        echo "warning: could not resolve cf-nix-cache secrets via secretspec; leaving $config_dir unchanged" >&2
      fi
      unset secrets
    fi
  '';
}
