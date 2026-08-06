{ ... }:
{
  imports = [
    ../../modules/darwin/system.nix
    ../../darwin/common
  ];

  username = "will";

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking = {
    computerName = "willmb";
    hostName = "willmb";
    localHostName = "willmb";
  };

  programs.helium.webApps = {
    gmail = {
      url = "https://mail.google.com/mail/?usp=installed_webapp";
      expectedBundleId = "net.imput.helium.app.fmgjjmmmlfnkbppncabfkddbjimcfncm";
      defaultLaunchContainer = "window";
    };
    outlook = {
      url = "https://outlook.office.com/mail/";
      expectedBundleId = "net.imput.helium.app.faolnafnngnfdaknnbpnkhgohbobgegn";
      defaultLaunchContainer = "window";
    };
  };

  system.stateVersion = 5;
}
