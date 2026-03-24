{ ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "system";
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
  programs.gemini-cli = {
    enable = true;
    settings = {
      general = {
        preferredEditor = "vim";
        previewFeatures = true;
      };
      security.auth.selectedType = "oauth-personal";
      ui.theme = "GitHub Light";
    };
  };
}
