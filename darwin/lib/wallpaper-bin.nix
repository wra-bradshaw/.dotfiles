{ pkgs, ... }:
(pkgs.stdenv.mkDerivation {
  pname = "wallpaper";
  version = "2.3.1";

  src = pkgs.fetchzip {
    url = "https://github.com/sindresorhus/macos-wallpaper/releases/download/v2.3.1/wallpaper.zip";
    sha256 = "sha256-SAs2ciOPY2VeGyFBdzXpmE7qkHnTugXvWjJ24r5Nz1M=";
  };

  nativeBuildInputs =
    [
    ];

  buildInputs =
    [
    ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src/wallpaper $out/bin/wallpaper
    runHook postInstall
  '';
})
