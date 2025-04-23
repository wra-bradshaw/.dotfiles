{ pkgs, ... }:
{
  programs.zotero = {
    enable = true;
    package = pkgs.brewCasks.zotero;
    profiles.default = {
      extensions =
        let

          buildZoteroXpiAddon = pkgs.makeOverridable (
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
            pname = "zotero-better-bibtex";
            version = "7.0.19";
            addonId = "zotero-better-bibtex@retorque.re";
            url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.19/zotero-better-bibtex-7.0.19.xpi";
            hash = "sha256-Dp71waix6VamzDjZDLm3CBc+ZwAEQRKqt8pOTFqB1No=";
          })
        ];
    };
  };
}
