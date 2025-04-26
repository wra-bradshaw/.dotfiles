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
      mineffect = "suck";
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
      KeyRepeat = 2; # make key repeat delay lower
      AppleShowAllExtensions = true; # show file extensions
      NSDocumentSaveNewDocumentsToCloud = false; # disable icloud save by default
      NSWindowResizeTime = 0.1;
      "com.apple.mouse.tapBehavior" = 1; # enable tap to click
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleInterfaceStyle = "Dark";
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
