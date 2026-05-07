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
            version = "0.19.0";
            addonId = "beaver@jlegewie.com";
            url = "https://github.com/jlegewie/beaver-zotero/releases/download/v0.19.0/beaver.xpi";
            hash = "sha256-56DlVCAbkdWxvqtGnfjyriyJO6YjSS4DC/S5xHLVwJI=";
          })
          (buildZoteroXpiAddon {
            pname = "zotero-better-bibtex";
            version = "9.0.23";
            addonId = "zotero-better-bibtex@retorque.re";
            url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.23/zotero-better-bibtex-9.0.23.xpi";
            hash = "sha256-CX6gwKn/1kyJQpWtN1LcBqmz8HuIBqhK7fnW/PQ1cXw=";
          })
        ];
    };
  };
}
