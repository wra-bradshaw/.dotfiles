{ config, ... }:
{
  system.defaults = {
    screencapture.location = "~/Downloads";

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.25;
      persistent-apps = [ ];
      mru-spaces = false;
      mineffect = "scale";
      expose-group-apps = true;
    };

    CustomUserPreferences = {
      "com.apple.finder".NewWindowTargetPath = "file:///Users/${config.username}/";
    };

    finder = {
      FXDefaultSearchScope = "SCcf";
    };

    NSGlobalDomain = {
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
    };
  };

  services.colima = {
    enable = false;
    enableDockerCompatability = true;
    groupMembers = [ "${config.username}" ];
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
