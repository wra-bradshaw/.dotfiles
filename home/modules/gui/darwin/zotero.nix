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
            version = "0.26.3";
            addonId = "beaver@jlegewie.com";
            url = "https://github.com/jlegewie/beaver-zotero/releases/download/v0.26.3/beaver.xpi";
            hash = "sha256-6W1uixFo+BWisl2m2GI2/pZbUUP2qQrgpHFSGgnR5zc=";
          })
          (buildZoteroXpiAddon {
            pname = "zotero-better-bibtex";
            version = "9.0.77";
            addonId = "zotero-better-bibtex@retorque.re";
            url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.77/zotero-better-bibtex-9.0.77.xpi";
            hash = "sha256-pfHSuvj/QshXYbej2PZ5n/wwbwgugCTVuDzoDoWSvQs=";
          })
        ];
    };
  };
}
