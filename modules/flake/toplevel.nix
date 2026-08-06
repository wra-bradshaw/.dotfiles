{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
  ];

  perSystem =
    { pkgs, self', ... }:
    {
      formatter = pkgs.nixfmt-tree;
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          deadnix
          nixd
          nixfmt
          statix
        ];
      };
      packages.default = self'.packages.activate;
    };
}
