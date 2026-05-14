{ ... }:
(final: prev: {
  socktainer = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "socktainer";
    version = "0.12.0";
    src = prev.fetchurl {
      url = "https://github.com/socktainer/socktainer/releases/download/v${finalAttrs.version}/socktainer";
      hash = "sha256-monlqaAmScUAcxnV5Q4LikHmylyWzEAiqsBbcbE/2ns=";
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
