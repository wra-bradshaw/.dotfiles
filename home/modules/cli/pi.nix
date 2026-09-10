{ pkgs, ... }:
{
  programs.pi-coding-agent = {
    enable = true;

    extraPackages = with pkgs; [
      nodejs
      git
      jq
      ripgrep
      fd
    ];

    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "muse-spark-1.3-contributor";
      defaultThinkingLevel = "xhigh";

      npmCommand = [ "${pkgs.nodejs}/bin/npm" ];
      packages = [
        "npm:@quintinshaw/pi-dynamic-workflows@3.10.0"
      ];
    };
  };

  home.file = {
    ".agents/skills/anki-connect/SKILL.md".source = ../../pi/skills/anki-connect/SKILL.md;
  };
}
