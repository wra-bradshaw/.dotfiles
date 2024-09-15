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
    yt-dlp
    gcc
    kalker
    ffmpeg
    unzip
    lazygit
    nix-output-monitor
    ripgrep
    jq
    devenv
    mariadb
    fnm
  ];
}
