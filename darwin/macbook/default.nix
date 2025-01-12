{ pkgs, config, ... }:
{
  imports = [
    ../common
  ];

  options.username =
    with pkgs.lib;
    mkOption {
      type = types.str;
      default = "will";
      description = "The username of the default/main admin user";
    };
}
