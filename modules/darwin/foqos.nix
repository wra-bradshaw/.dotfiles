{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.foqos;
  appName = "Foqos for Mac.app";
in
{
  options.programs.foqos.enable = lib.mkEnableOption "the Foqos for Mac GUI application";

  config = lib.mkIf cfg.enable {
    system.activationScripts.applications.text = lib.mkAfter ''
      install -o root -g wheel -m0555 -d ${lib.escapeShellArg "/Applications/${appName}"}

      rsyncFlags=(
        # mtime is standardized in the nix store, which would leave only file size to distinguish files.
        # Thus we need checksums, despite the speed penalty.
        --checksum
        # Converts all symlinks pointing outside of the copied tree (thus unsafe) into real files and directories.
        # This neatly converts all the symlinks pointing to application bundles in the nix store into
        # real directories, without breaking any relative symlinks inside of application bundles.
        --copy-unsafe-links
        --archive
        --delete
        --chmod=-w
        --no-group
        --no-owner
      )

      ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" \
        ${lib.escapeShellArg "${pkgs.foqos}/Applications/${appName}/"} ${lib.escapeShellArg "/Applications/${appName}"}
    '';
  };
}
