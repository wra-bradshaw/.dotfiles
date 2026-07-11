{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fd
    python3
    dig
    timewarrior
    gh
    nodejs-slim
    nodejs-slim.npm
    pnpm
    yarn
    parallel
    sops
    bun
    docker
    pandoc
    ripgrep
    uv
    aria2
    lldb
    htop-vim
    wget
    gcc
    ngrok
    terraform
    antigravity-cli
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
    mariadb
    shellcheck
    shfmt
    annas-mcp
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
