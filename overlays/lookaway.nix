# NEVER UPDATE: deliberately held at 2.4.11
_:
(_final: prev: {
  lookaway = prev.stdenv.mkDerivation {
    pname = "lookaway";
    version = "2.4.11";

    src = prev.fetchurl {
      url = "https://github.com/mysticalbits/lookaway-releases/releases/download/2.4.11/LookAway.dmg";
      hash = "sha256-KmVPptUrkL5dSSRPO3zLpZ8CpZVPNdKqlwOgm/qkE2c=";
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
      cp -R "LookAway/LookAway.app" "$out/Applications/"
      runHook postInstall
    '';

    meta = {
      description = "LookAway — break time reminder app";
      homepage = "https://lookaway.com/";
      license = prev.lib.licenses.unfree;
      platforms = prev.lib.platforms.darwin;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  };
})
