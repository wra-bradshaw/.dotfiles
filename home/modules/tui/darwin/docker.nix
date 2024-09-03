{pkgs, ...}: {
  home.packages = [
    pkgs.docker
    pkgs.colima
  ];
}
