{ pkgs, lib, ... }:
{
  programs.zotero = {
    enable = true;
    package = pkgs.brewCasks.zotero;
    profiles.default = {
      extensions =
        let

          buildZoteroXpiAddon = lib.makeOverridable (
            {
              stdenv ? pkgs.stdenv,
              fetchurl ? pkgs.fetchurl,
              pname,
              version,
              addonId,
              url,
              hash,
              meta ? { },
              ...
            }:
            stdenv.mkDerivation {
              name = "${pname}-${version}";

              inherit meta;

              src = fetchurl { inherit url hash; };

              preferLocalBuild = true;
              allowSubstitutes = true;

              buildCommand = ''
                dst="$out/share/zotero/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
                mkdir -p "$dst"
                install -v -m644 "$src" "$dst/${addonId}.xpi"
              '';
            }
          );
        in
        [
          (buildZoteroXpiAddon {
            pname = "beaver";
            version = "0.23.1";
            addonId = "beaver@jlegewie.com";
            url = "https://github.com/jlegewie/beaver-zotero/releases/download/v0.23.1/beaver.xpi";
            hash = "sha256-wgelSy7VmQGP39r3coBtj1xyNTwwpzR89MPgh7yGrwg=";
          })
          (buildZoteroXpiAddon {
            pname = "zotero-better-bibtex";
            version = "9.0.55";
            addonId = "zotero-better-bibtex@retorque.re";
            url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.55/zotero-better-bibtex-9.0.55.xpi";
            hash = "sha256-LZFOuxdMLFkOz/dBppA/GXkGW0J0DzAdk47Cy2wD5NY=";
          })
        ];
    };
  };
}
