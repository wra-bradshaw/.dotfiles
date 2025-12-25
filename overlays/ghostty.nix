{ }:
(final: prev: {
  ghostty-bin = prev.ghostty-bin.overrideAttrs (oldAttrs: {
    version = "tip";
  });
})
