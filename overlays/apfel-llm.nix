_:
(_final: prev: {
  apfel-llm = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "apfel";
    version = "1.20.0";

    src = prev.fetchzip {
      url = "https://github.com/Arthur-Ficial/apfel/releases/download/v${finalAttrs.version}/apfel-${finalAttrs.version}-arm64-macos.tar.gz";
      sha256 = "sha256-DNt+kVMqZnTH148ezx+VrhrjHIQxcvJ5dPRRYYFZjr4=";
      stripRoot = false;
    };

    dontUnpack = false;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp apfel $out/bin/apfel
      chmod +x $out/bin/apfel
    '';
  });
})
