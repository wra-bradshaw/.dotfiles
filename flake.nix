{
  description = "Will's macOS and NixOS systems";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*";

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
