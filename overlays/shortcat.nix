{ ... }:
(final: prev: {
  shortcat = prev.shortcat.overrideAttrs (oldAttrs: rec {
    version = "0.12.2";

    src = prev.fetchurl {
      url = "https://files.shortcat.app/releases/v${version}/Shortcat.zip";
      sha256 = "sha256-jmp9mBMYID0Zcu/o6ICYPS8QGHhSwcLz072jG3zR2mM=";
    };
  });
})
