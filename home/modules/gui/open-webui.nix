{ ... }:
{
  services.open-webui = {
    enable = false;
    stateDir = /Users/will/.local/state/open-webui;
    port = 5090;
    environment = {
      "WEBUI_AUTH" = "False";
    };
  };
}
