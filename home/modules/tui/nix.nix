{ nixpkgs, ... }:
{
  nix.registry.nixpkgs.flake = nixpkgs;
  nix.settings = {
    use-sandbox = true;
    show-trace = true;
  };
}
