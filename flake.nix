{
  description = "System Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    nur.url = "github:nix-community/NUR";

    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    xremap-flake.url = "github:xremap/nix-flake";
    xremap-flake.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.3.0";

    mac-app-util.url = "github:hraban/mac-app-util";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      lib = import ./lib.nix { inherit nixpkgs supportedSystems; };

      homeManagerModules = [
        inputs.nixvim.homeManagerModules.nixvim
        inputs.nur.nixosModules.nur
        inputs.nix-colors.homeManagerModules.default
      ];

      homeManagerModulesDarwin = [ inputs.mac-app-util.homeManagerModules.default ] ++ homeManagerModules;

      homeManagerModulesLinux = [
        inputs.xremap-flake.homeManagerModules.default
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ] ++ homeManagerModules;

      homeSharedModulesLinux = [ inputs.sops-nix.homeManagerModules.sops ];

      homeManagerExtraSpecialArgs = {
        nixpkgs = nixpkgs;
        nix-colors = inputs.nix-colors;
      };

      homeManagerExtraSpecialArgsLinux = {
        xremap-flake = inputs.xremap-flake;
      };

      homeManagerExtraSpecialArgsDarwin = {
        sops-nix = inputs.sops-nix;
      };

      darwinModules = [
        inputs.brew-nix.darwinModules.default
        inputs.mac-app-util.darwinModules.default
        ./nixpkgs.nix
      ];

      darwinSpecialArgs = { };

      nixosModules = [
        inputs.sops-nix.nixosModules.sops
        inputs.nix-flatpak.nixosModules.nix-flatpak
        ./nixpkgs.nix
      ];

      nixosSpecialArgs = { };
    in
    {
      devShells = lib.forAllSupportedSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              (pkgs.writeShellScriptBin "apply-nixos" ''
                set -euox pipefail
                pushd ~/.dotfiles
                sudo nixos-rebuild switch --log-format internal-json -v --upgrade --flake .#$1 |& ${pkgs.nix-output-monitor}/bin/nom --json
                popd
              '')

              (pkgs.writeShellScriptBin "apply-darwin" ''
                set -euox pipefail
                pushd ~/.dotfiles
                ${inputs.nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild switch --flake ".#$1"
                popd
              '')

              inputs.deploy-rs.defaultPackage.${system}
            ];
          };
        }
      );

      darwinConfigurations = {
        macbook = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = darwinSpecialArgs;
          modules = [
            ./darwin/macbook
            inputs.home-manager.darwinModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = homeManagerExtraSpecialArgs // homeManagerExtraSpecialArgsDarwin;
                  users.${config.username}.imports = [
                    ./home/hosts/macbook
                    (
                      { pkgs, ... }:
                      {
                        options.username =
                          with pkgs.lib;
                          mkOption {
                            type = types.str;
                            default = config.username;
                            description = "The username of the user";
                          };
                      }
                    )
                  ] ++ homeManagerModulesDarwin;
                };
              }
            )
          ] ++ darwinModules;
        };
      };

      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = nixosSpecialArgs;
          modules = [
            ./nixos/desktop
            inputs.home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  sharedModules = homeSharedModulesLinux;
                  extraSpecialArgs = homeManagerExtraSpecialArgs // homeManagerExtraSpecialArgsLinux;
                  users.${config.username}.imports = [
                    ./home/hosts/desktop
                    (
                      { pkgs, ... }:
                      {
                        options.username =
                          with pkgs.lib;
                          mkOption {
                            type = types.str;
                            default = config.username;
                            description = "The username of the user";
                          };
                      }
                    )
                  ] ++ homeManagerModulesLinux;
                };
              }
            )
          ] ++ nixosModules;
        };

        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = nixosSpecialArgs;
          modules = [
            ./nixos/server
            # microvm.nixosModules.microvm
          ] ++ nixosModules;
        };

        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = nixosSpecialArgs;
          modules = [
            ./nixos/laptop
            inputs.home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  sharedModules = homeSharedModulesLinux;
                  extraSpecialArgs = homeManagerExtraSpecialArgs // homeManagerExtraSpecialArgsLinux;
                  users.${config.username}.imports = [
                    ./home/hosts/laptop
                    (
                      { pkgs, ... }:
                      {
                        options.username =
                          with pkgs.lib;
                          mkOption {
                            type = types.str;
                            default = config.username;
                            description = "The username of the user";
                          };
                      }
                    )
                  ] ++ homeManagerModulesLinux;
                };
              }
            )
          ] ++ nixosModules;
        };
      };

      deploy.nodes.server = {
        hostname = "server.squeaker-eel.ts.net";
        fastConnection = true;
        profiles = {
          system = {
            sshUser = "admin";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.server;
            user = "root";
          };
        };
      };
    };
}
