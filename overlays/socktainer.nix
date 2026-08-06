{ ... }:
(final: prev: {
  socktainer = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "socktainer";
    version = "1.2.1";
    src = prev.fetchurl {
      url = "https://github.com/socktainer/socktainer/releases/download/v${finalAttrs.version}/socktainer";
      hash = "sha256-MwSmK8HClALcOaRaHcdAmJBMneqCZ/etl//xrwIvrAs=";
    };
    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/bin";
      cp $src "$out/bin/socktainer";
      chmod +x "$out/bin/socktainer";
    '';

    meta = {
      mainProgram = "socktainer";
    };
  });
})
