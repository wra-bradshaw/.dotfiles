{
  config,
  lib,
  pkgs,
  ...
}:

let
  appsSrc = "$newGenPath/home-path/Applications";

  baseDir = "${config.home.homeDirectory}/Applications/Home Manager Apps";

  copyScript = ''
    appsSrc="${appsSrc}"
    if [ -d "$appsSrc" ]; then
      baseDir="${baseDir}"
      rsyncFlags=(
        --archive
        --checksum
        --chmod=-w
        --copy-unsafe-links
        --delete
        --no-group
        --no-owner
      )
      $DRY_RUN_CMD mkdir -p "$baseDir"
      $DRY_RUN_CMD ${lib.getBin pkgs.rsync}/bin/rsync \
        ''${VERBOSE_ARG:+-v} "''${rsyncFlags[@]}" "$appsSrc/" "$baseDir"
    fi
  '';
in
{
  disabledModules = [ "targets/darwin/linkapps.nix" ];
  config = {
    home.activation.copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] copyScript;
  };
}

