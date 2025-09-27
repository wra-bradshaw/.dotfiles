{ ... }:
(final: prev: {
  brewCasks = prev.brewCasks // {
    messenger = prev.brewCasks.messenger.overrideAttrs (oldAttrs: {
      src = prev.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-QBPj5TBdayybez+R/9mdfeueAOL6k1BI+yj0kMOO2Yc=";
      };
    });
  };
})
