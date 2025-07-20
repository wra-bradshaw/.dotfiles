{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    parallel
    sops
    pandoc
    ripgrep
    uv
    rimage
    aria2
    gemini-cli
    opencode
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
    shellcheck
    shfmt
    (pkgs.buildGoModule (finalAttrs: {
      pname = "podsync";
      version = "2.8.0";

      src = pkgs.fetchFromGitHub {
        owner = "mxpv";
        repo = "podsync";
        tag = "v${finalAttrs.version}";
        hash = "sha256-xuUwvbK8s/EtrYgXRAr8rLH8VNgaTbzUV8gdHfP5enI=";
      };

      vendorHash = "sha256-joKl5p8oOdvK7osdBrCz4vNoB5/u6G8thtd2XjVJRXI=";
    }))
  ];
}
