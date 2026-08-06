{ config, pkgs, ... }:
{
  documentation.enable = false;
  home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash";
  system = {
    tools.darwin-uninstaller.enable = false;
    defaults = {
      screencapture.location = "~/Downloads";

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.25;
        persistent-apps = [ ];
        mru-spaces = false;
        mineffect = "scale";
        expose-group-apps = true;
        tilesize = 60;
        wvous-br-corner = 14;
      };

      CustomUserPreferences = {
        "com.apple.finder".NewWindowTargetPath = "file:///Users/${config.username}/";
        NSGlobalDomain."SLSMenuBarUseBlurredAppearance" = false;
      };

      finder = {
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        NSWindowShouldDragOnGesture = true;
        ApplePressAndHoldEnabled = false;
        AppleICUForce24HourTime = true; # use 24 hr time
        AppleShowAllFiles = true; # show hidden files
        InitialKeyRepeat = 15; # make initial key repeat delay shorter
        KeyRepeat = 3;
        AppleShowAllExtensions = true; # show file extensions
        NSDocumentSaveNewDocumentsToCloud = false; # disable icloud save by default
        NSWindowResizeTime = 0.1;
        "com.apple.mouse.tapBehavior" = 1; # enable tap to click
        AppleInterfaceStyleSwitchesAutomatically = true;
        _HIHideMenuBar = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  time.timeZone = "Australia/Melbourne";
  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
    };
    knownNetworkServices = [
      "USB 10/100/1000 LAN"
      "Wi-Fi"
      "iPhone USB"
    ];
    dns = [
      "9.9.9.9"
      "149.112.112.112"
    ];
  };
  services.openssh.enable = true;
}
