{ ... }:
(final: prev: {
  modrinth-app = prev.modrinth-app.overrideAttrs (old: {
    buildCommand = builtins.replaceStrings [ "wrapGAppsHook" ] [ ''wrapGApp "$out/bin/ModrinthApp"'' ] old.buildCommand;
  });
})
