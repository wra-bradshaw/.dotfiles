{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.opencode = {
    enable = true;
    extraPackages = with pkgs; [
      nodejs
    ];
    tui = {
      theme = "system";
      plugin = [ "@prevalentware/opencode-goal-plugin" ];
    };
    context = ''
      Math renders only as \(...\) inline and $$ on own lines for blocks. Never $...$ or single-line $$...$$.
    '';
    settings = {
      plugin = [ "@prevalentware/opencode-goal-plugin" ];
      mcp = {
        chrome-devtools = {
          type = "local";
          command = [
            "npx"
            "-y"
            "chrome-devtools-mcp@latest"
          ];
          enabled = true;
        };
      };
    };
  };

  services.opencode-serve = {
    enable = true;
    # programs.opencode already puts opencode (wrapped with nodejs) on PATH.
    # Installing cfg.package as well would collide on bin/opencode in buildEnv.
    installPackage = false;
    package = lib.mkDefault config.programs.opencode.package;
  };
}
