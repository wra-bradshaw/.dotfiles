{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isDarwin then
        (pkgs.brewCasks.eloston-chromium.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [
            pkgs.darwin.xattr
          ];
          fixupPhase = ''
            xattr -cr $out/Applications/Chromium.app
          '';
        }))
      else
        pkgs.ungoogled-chromium;
    dictionaries = [ pkgs.hunspellDictsChromium.en_GB ];
    extensions = [
      { id = "cjjieeldgoohbkifkogalkmfpddeafcm"; } # granted
      { id = "egnjhciaieeiiohknchakcodbpgjnchh"; } # tab wrangler
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "dinhbmppbaekibhlomcimjbhdhacoael"; } # ad skipper
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock origin lite
    ];
  };
}
