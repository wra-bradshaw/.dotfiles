_: _final: prev:
let
  version = "0.22.1.1";
in
{
  helium =
    if prev.stdenv.hostPlatform.isDarwin then
      prev.stdenv.mkDerivation {
        pname = "helium";
        inherit version;
        src = prev.fetchurl {
          url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
          hash = "sha256-jCNEgMASI8nbyejcW8W+CLjkNBQ31i2unXWUK1lPvVE=";
        };
        nativeBuildInputs = [
          prev._7zz
          prev.makeWrapper
        ];
        unpackPhase = "7zz x -snld $src";
        dontPatchShebangs = true;
        dontStrip = true;
        sourceRoot = ".";
        installPhase = ''
          mkdir -p "$out/Applications"
          if [ -d "Helium.app" ]; then
            cp -R "Helium.app" "$out/Applications/Helium.app"
          elif [ -d "Helium/Helium.app" ]; then
            cp -R "Helium/Helium.app" "$out/Applications/Helium.app"
          else
            echo "Could not find Helium.app, contents:"
            ls -R | head -100
            exit 1
          fi
          mkdir -p "$out/bin"
          makeWrapper "$out/Applications/Helium.app/Contents/MacOS/Helium" "$out/bin/helium"
        '';
        meta.mainProgram = "helium";
      }
    else
      prev.appimageTools.wrapType2 {
        pname = "helium";
        inherit version;
        src = prev.fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-arm64.AppImage";
          hash = "sha256-4+BJ/cFfHDsYU+azrOvuXIjbC7hnJ2q0DFj1ulR5TQs=";
        };
        meta.mainProgram = "helium";
      };
}
