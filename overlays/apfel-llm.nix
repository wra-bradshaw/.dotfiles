_:
(_final: prev: {
  apfel-llm = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "apfel";
    version = "1.9.1";

    src = prev.fetchzip {
      url = "https://github.com/Arthur-Ficial/apfel/releases/download/v${finalAttrs.version}/apfel-${finalAttrs.version}-arm64-macos.tar.gz";
      sha256 = "sha256-buaQKZTxICkEzmdc73cX1oLVFt2TbAi7jb2fVgpNfwY=";
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
