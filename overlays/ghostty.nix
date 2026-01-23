{ }:
(final: prev: {
  ghostty-bin = prev.ghostty-bin.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "tip";
      src = prev.fetchurl {
        url = "https://github.com/ghostty-org/ghostty/releases/download/${finalAttrs.version}/Ghostty.dmg";
        hash = "sha256-iqNQkJ4+riNPrDEBnaSu15eJHG7T3kz+5rlB4AsdUms=";
      };
    }
  );
})
