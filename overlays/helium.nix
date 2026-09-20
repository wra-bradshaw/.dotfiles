_: _final: prev:
let
  version = "0.17.2.1";
in
{
  helium =
    if prev.stdenv.hostPlatform.isDarwin then
      prev.stdenv.mkDerivation {
        pname = "helium";
        inherit version;
        src = prev.fetchurl {
          url = "https://github.com/imputnet/helium-macos/releases/download/${version}/helium_${version}_arm64-macos.dmg";
          hash = "sha256-8aP+zePAglTxse7DDjbs0l+YzzeZZEQn+879bmvq+s8=";
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
          hash = "sha256-VNVETBXVO1skExhK3maw7N/HuFufeHRky/z1CRwjqkw=";
        };
        meta.mainProgram = "helium";
      };
}
