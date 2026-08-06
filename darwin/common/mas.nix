{ config, ... }:
{
  programs.mas = {
    enable = true;
    user = config.username;
    update = false;
    packages = {
      "Compressor Creator Studio" = 6746516157;
      "DaVinci Resolve" = 571213070;
      HEVCut = 6737538832;
      "Final Cut Pro Creator Studio" = 1631624924;
      "Keynote Creator Studio" = 361285480;
      "Logic Pro Creator Studio" = 1615087040;
      "MainStage Creator Studio" = 6746637089;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "Motion Creator Studio" = 6746637149;
      Noir = 1592917505;
      "Numbers Creator Studio" = 361304891;
      "Pages Creator Studio" = 361309726;
      "Pixelmator Pro Creator Studio" = 6746662575;
      Prodrafts = 1545810067;
      TestFlight = 899247664;
      Vinegar = 1591303229;
      WhatsApp = 310633997;
      Wipr = 1662217862;
    };
  };
}
