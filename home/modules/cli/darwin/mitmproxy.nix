{ pkgs, ... }:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home.packages = [ pkgs.mitmproxy ];

  home.file.".mitmproxy/config.yaml".source = yamlFormat.generate "mitmproxy-config.yaml" {
    proxy_debug = false;
    console_eventlog_verbosity = "error";
  };
}
