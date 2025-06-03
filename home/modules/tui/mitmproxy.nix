{ pkgs, ... }:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home.packages = with pkgs; [
    mitmproxy
    mitmproxy2swagger
  ];

  home.file.".mitmproxy/config.yaml".source = yamlFormat.generate "config.yaml" {
    proxy_debug = false;
    console_eventlog_verbosity = "error";
  };
}
