{ ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "system";
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
