_: {
  programs.opencode = {
    enable = true;
    tui.theme = "system";
    settings = {
      plugin = [ ];
      permission = {
        edit = "ask";
        webfetch = "allow";
        external_directory = "ask";
        doom_loop = "ask";
        bash = {
          "*" = "ask";
          "ls *" = "allow";
          "grep *" = "allow";
          "bun run build" = "allow";

        };
      };
    };
  };
}
