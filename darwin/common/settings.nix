{ config, ... }:
{
  system.defaults = {
    screencapture.location = "/tmp";

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.25;
      persistent-apps = [ ];
    };

    CustomUserPreferences = {
      "com.apple.finder".NewWindowTargetPath = "file:///Users/${config.username}/";
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

    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
