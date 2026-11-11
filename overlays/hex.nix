_:
(_final: prev: {
  hex = prev.stdenv.mkDerivation {
    pname = "hex";
    version = "3.4.0";

    src = prev.fetchurl {
      url = "https://github.com/anomalyco/hex/releases/download/v3.4.0/hex-3.4.0-macos-arm64.dmg";
      hash = "sha256-GnHmKVWSTk5RwoyjxYZ632xq8vwpF5o1TwhDNDp6/EQ=";
    };

    nativeBuildInputs = [ prev._7zz ];

    dontStrip = true;

    unpackPhase = ''
      runHook preUnpack
      7zz x -snld "$src"
      find . -name '*:com.apple.provenance' -delete
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R "Hex.app" "$out/Applications/"
      runHook postInstall
    '';

    meta = {
      description = "Hex — local-first voice dictation";
      homepage = "https://anoma.ly/hex";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.darwin;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  };
})
