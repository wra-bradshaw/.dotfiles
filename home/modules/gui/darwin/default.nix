{ flake, ... }:
{
  imports = [
    flake.inputs.neru.homeManagerModules.default
    ./packages.nix
    ./paneru.nix
    # ./omniwm.nix # disabled in favor of paneru; kept for easy rollback
    ./ghostty.nix
    ./rex.nix
    ./zotero.nix
    ./copy-apps.nix
    ./neru.nix
    ./chromium-module.nix
    ./zotero-module.nix
  ];
}
