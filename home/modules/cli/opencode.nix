_: {
  programs.opencode = {
    enable = true;
    tui.theme = "system";
    settings = {
      plugin = [ ];
    };
  };

  services.opencode-serve.enable = true;
}
