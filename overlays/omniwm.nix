{ ... }:
(final: prev: {
  omniwm = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "omniwm";
    version = "0.4.8.1";

    src = prev.fetchurl {
      url = "https://github.com/BarutSRB/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
      hash = "sha256-f2ByexWwgc9qzUC0wbXf0nDIMl4w1xtuUfXpmzA/CFc=";
    };

    nativeBuildInputs = [
      prev.unzip
    ];

    sourceRoot = "OmniWM.app";

    installPhase = ''
      mkdir -p $out/Applications/OmniWM.app
      mkdir -p $out/bin
      cp Contents/MacOS/omniwmctl $out/bin/omniwmctl
      cp -R . $out/Applications/OmniWM.app
    '';
  });
})
