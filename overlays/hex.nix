_:
(_final: prev: {
  hex = prev.stdenv.mkDerivation {
    pname = "hex";
    version = "3.3.0";

    src = prev.fetchurl {
      url = "https://anoma.ly/release/hex/files/c57106949a28a3d0767cc15505cd802638badeb0c18cfd06c57b130ab0d98859/Hex.dmg";
      hash = "sha256-xXEGlJooo9B2fMFVBc2AJji63rDBjP0GxXsTCrDZiFk=";
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
