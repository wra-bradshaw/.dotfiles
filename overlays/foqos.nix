_:
(_final: prev: {
  foqos = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "foqos";
    version = "0.1.6";

    src = prev.fetchurl {
      url = "https://github.com/awaseem/foqos/releases/download/mac-v${finalAttrs.version}/Foqos-for-Mac-${finalAttrs.version}.dmg";
      hash = "sha256-yNmqNg0kAv8+7pkDOr9JyBZBaM1qIFIvQkotMr4IEC4=";
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
      cp -R "Foqos for Mac/Foqos for Mac.app" "$out/Applications/"
      runHook postInstall
    '';

    meta = {
      description = "Foqos for Mac — companion menu-bar website blocker";
      homepage = "https://github.com/awaseem/foqos";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.darwin;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  });
})
