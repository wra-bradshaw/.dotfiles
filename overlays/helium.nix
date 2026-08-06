_: _final: prev:
let
  version = "0.15.2.1";
in
{
  helium =
    if prev.stdenv.hostPlatform.isDarwin then
      prev.stdenv.mkDerivation {
        pname = "helium";
        inherit version;
        src = prev.fetchurl {
          url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
          hash = "sha256-+onoZkK37fwg0upK0A03xGmMORC0e8+ozeHqN/2j/X8=";
        };
        nativeBuildInputs = [
          prev._7zz
          prev.makeWrapper
        ];
        unpackPhase = "7zz x -snld $src";
        dontPatchShebangs = true;
        dontStrip = true;
        sourceRoot = "Helium.app";
        installPhase = ''
          mkdir -p "$out/Applications/Helium.app"
          cp -R . "$out/Applications/Helium.app"
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
          hash = "sha256-73KXJ2H8FGNt5VTg/9cdkbRfRVgafxwRRe4DQlbM408=";
        };
        meta.mainProgram = "helium";
      };
}
