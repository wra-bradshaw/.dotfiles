{
  config,
  pkgs,
  lib,
  ...
}:
let
  heliumUserDataDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/net.imput.helium"
    else
      "${config.home.homeDirectory}/.config/helium";
in
{
  programs.opencode = {
    enable = true;
    extraPackages = with pkgs; [
      nodejs
    ];
    cli = {
      theme.name = "system";
      diffs.wrap = "word";
      session = {
        sidebar = "auto";
        scrollbar = false;
        thinking = "hide";
      };
      animations = true;
      tabs.mode = "off";
    };
    context = ''
      Always write math in LaTeX. Inline math is written inline in `\( ... \)`. Display/block level math is written in `$$ ... $$` on _its own new line_.
    '';
    settings = {
      mcp = {
        chrome-devtools = {
          type = "local";
          command = [
            "${pkgs.chrome-devtools-mcp}/bin/chrome-devtools-mcp"
            "--autoConnect"
            "--userDataDir=${heliumUserDataDir}"
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
