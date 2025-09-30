{ pkgs, ... }:
let
  extensionIds = [
    "egnjhciaieeiiohknchakcodbpgjnchh" # tab wrangler
    "ecboojkidbdghfhifefbpdkdollfhicb" # ddg bangs
    "ekhagklcjbdpajgpjgmbionohlpdbjgc" # zotero connector
    "nngceckbapebfimnlniiiahkandclblb" # bitwaden
    "dhdgffkkebhmkfjojejmpbldmpobfkfo" # tampermonkey
    "hkligngkgcpcolhcnkgccglchdafcnao" # web archives
    "ddkjiahejlhfcafbddmgiahcphecmpfh" # ubol lite
  ];
in
{
  programs.brave = {
    enable = true;
    package = pkgs.brave;
    dictionaries = [ pkgs.hunspellDictsChromium.en_GB ];
    extensions = map (id: { id = id; }) extensionIds;
  };

  # home.file = pkgs.lib.optionalAttrs (pkgs.stdenv.isDarwin) builtins.listToAttrs (
  #   map (id: {
  #     name = "Library/Application Support/Google/Chrome/External Extensions/${id}.json";
  #     value = {
  #       text = builtins.toJSON {
  #         external_update_url = "https://clients2.google.com/service/update2/crx";
  #       };
  #     };
  #   }) extensionIds
  # );
}
