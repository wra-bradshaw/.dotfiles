{ ... }: {
  programs.nix-your-shell = {
    enable = true;
    enableZshIntegration = true; # or fish/nushell
    nix-output-monitor.enable = true;
  };
}
