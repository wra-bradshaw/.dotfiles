{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    (awscli2.overrideAttrs (old: {
      makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
        "--unset"
        "PYTHONPATH"
      ];
    }))
    parallel
    sops
    ripgrep
    aria2
    htop-vim
    wget
    yt-dlp
    gcc
    ngrok
    terraform
    kalker
    watchexec
    ffmpeg
    unzip
    nix-output-monitor
    xz
    readline
    ripgrep
    jq
    yq-go
    devenv
    mariadb
    fnm
  ];
}
