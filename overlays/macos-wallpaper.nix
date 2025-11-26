{ ... }:
(final: prev: {
  macos-wallpaper = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "wallpaper";
    version = "2.3.3";

    src = prev.fetchzip {
      url = "https://github.com/sindresorhus/macos-wallpaper/releases/download/v${finalAttrs.version}/wallpaper.zip";
      sha256 = "sha256-KFgQqahrvkZyEM55GDniTol5uojd9GdmaGUHDlMxS6o=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src/wallpaper $out/bin/wallpaper
      chmod +x $out/bin/wallpaper
    '';
  });
})
