{ pkgs, ... }:
{
  services.neru = {
    enable = true;
    package = pkgs.neru-source.override {
      buildGoModule = pkgs.buildGoModule.override {
        go = pkgs.go_1_26;
      };
    };
  };
}
