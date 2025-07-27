{ pkgs, ... }:
let
  extensionIds = [
    "cjjieeldgoohbkifkogalkmfpddeafcm" # granted
    "egnjhciaieeiiohknchakcodbpgjnchh" # tab wrangler
    "dinhbmppbaekibhlomcimjbhdhacoael" # ad skipper
    "ddkjiahejlhfcafbddmgiahcphecmpfh" # ublock origin lite
    "oobpkmpnffeacpnfbbepbdlhbfdejhpg" # ddg bangs
    "oemmndcbldboiebfnladdacbdfmadadm" # pdf.js
    "ekhagklcjbdpajgpjgmbionohlpdbjgc" # zotero connector
  ];
in
{
  programs.chromium = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isDarwin then
        (pkgs.brewCasks.google-chrome.overrideAttrs (old: {
          name = "google-chrome";
          src = pkgs.fetchurl {
            url = builtins.head old.src.urls;
            hash = "sha256-OXa07MVYa7J4S/PkFJZ6RCEXXlzTkZig2WQBilFxbqM=";
          };
        }))
      else
        pkgs.chromium;
    dictionaries = [ pkgs.hunspellDictsChromium.en_GB ];
    extensions = map (id: { id = id; }) extensionIds;
  };

  home.file = pkgs.lib.optionalAttrs (pkgs.stdenv.isDarwin) builtins.listToAttrs (
    map (id: {
      name = "Library/Application Support/Google/Chrome/External Extensions/${id}.json";
      value = {
        text = builtins.toJSON {
          external_update_url = "https://clients2.google.com/service/update2/crx";
        };
      };
    }) extensionIds
  );
}
