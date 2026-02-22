{
  config,
  lib,
  pkgs,
  ...
}:

{
  targets.darwin.copyApps = {
    enable = true;
  };
}
