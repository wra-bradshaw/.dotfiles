{ ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "system";
      plugin = [ "opencode-gemini-auth" ];
      permission = {
        edit = "ask";
        webfetch = "allow";
        external_directory = "ask";
        doom_loop = "ask";
        bash = "ask";
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
