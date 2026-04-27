{ ... }:
(final: prev: {
  omniwm = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "omniwm";
    version = "0.4.7.4";

    src = prev.fetchurl {
      url = "https://github.com/BarutSRB/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
      hash = "sha256-6POMtHn5R1CQcz29QORrJaEuBxMPe7aYTtn0VWpQXIo=";
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
