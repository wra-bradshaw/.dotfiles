{ pkgs, ... }: {
  home.packages = with pkgs; [
    dig
    awscli2
    parallel
    sops
    ripgrep
    aria2
    htop-vim
    yt-dlp
    gcc
    kalker
    ffmpeg
    unzip
    nix-output-monitor
    ripgrep
    jq
    devenv
    mariadb
  ];
}
