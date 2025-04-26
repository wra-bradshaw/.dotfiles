{ pkgs, lib, ... }:
{
  nixpkgs.overlays = lib.mkAfter [
    (final: prev: rec {
      glfw = final.glfw-wayland-minecraft;

      prismlauncher = prev.prismlauncher.override { glfw = final.glfw-wayland-minecraft; };
    })
  ];
}
