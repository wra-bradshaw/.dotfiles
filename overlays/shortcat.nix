{ ... }:
(final: prev: {
  shortcat = prev.shortcat.overrideAttrs (oldAttrs: rec {
    version = "0.12.0";

    src = prev.fetchurl {
      url = "https://files.shortcat.app/releases/v${version}/Shortcat.zip";
      sha256 = "sha256-lEcmvqWEToPuoVFsHyeFfjQzIq4MhSNQMkG9QWvbHQA=";
    };
  });
})
