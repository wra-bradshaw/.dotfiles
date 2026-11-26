{
  description = "Will's macOS and NixOS systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/619c39f6eac5d1ed6b8f073a9414baf7034b2356";
    # TODO: Remove workaround: vtsls isn't cached for aarch64-darwin at the main nixpkgs revision (https://hydra.nixos.org/job/nixpkgs/unstable/vtsls.aarch64-darwin); drop this input and overlays/vtsls.nix together once select-nixpkgs.py reports it cached there
    nixpkgs-vtsls.url = "github:NixOS/nixpkgs/f4a03c008967841f2a0b3cb7c436fc6fc31671f6";
    # TODO: Remove workaround: harlequin isn't cached for aarch64-linux at the main nixpkgs revision (https://hydra.nixos.org/job/nixpkgs/unstable/harlequin.aarch64-linux); drop this input and overlays/harlequin.nix together once select-nixpkgs.py reports it cached there
    nixpkgs-harlequin.url = "github:NixOS/nixpkgs/93a9ed0a866099a230ed5146a5bb7d16fd5c9b14";

    flake-parts.url = "https://flakehub.com/f/hercules-ci/flake-parts/0.1.*";
    nixos-unified = {
      url = "github:srid/nixos-unified";
    };

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neru = {
      url = "https://flakehub.com/f/y3owk1n/neru/0.1.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snap = {
      url = "github:wra-bradshaw/snap";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cf-nix-cache = {
      url = "github:wra-bradshaw/cf-nix-cache";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: Remove workaround: codex fails under nixpkgs' new cargoUseSystemLibs hook and is uncached on aarch64-darwin; drop this input and overlays/codex.nix together once the main nixpkgs lock includes https://github.com/NixOS/nixpkgs/commit/16b463698a5b9f20881b6c5f1150ce37e2456db9
    nixpkgs-codex = {
      url = "github:NixOS/nixpkgs/e21fec321d73511849707a7585e4ea155ee4bf40";
    };
    dilly-dally = {
      url = "github:wra-bradshaw/dilly-dally";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./modules/flake/toplevel.nix ];
    };
}
