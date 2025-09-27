{ ... }:
(final: prev: {
  socktainer = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "socktainer";
    version = "0.2.0";
    src = prev.fetchurl {
      url = "https://github.com/socktainer/socktainer/releases/download/v${finalAttrs.version}/socktainer";
      hash = "sha256-LphrgL0dRXYuASxZgxjlZLKHx0wJBmqYzyW8jb5fTGI=";
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
