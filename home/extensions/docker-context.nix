{
  pkgs,
  lib,
  config,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  cfg = config.programs.docker-cli;
in
{
  options.programs.docker-cli.contexts = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        freeformType = jsonFormat.type;
        options.Name = lib.mkOption {
          type = lib.types.str;
          description = "The name of the Docker context";
        };
      }
    );
    default = [ ];
    example = lib.literalExpression ''
      [
        {
          Name = "example";
          Metadata = {
            Description = "example1";

          };
          Endpoints = {
            docker = {
              Host = "unix://example2";
            };
          };
        }
      ];
    '';
    description = ''
      Array of docker context configurations. See:
      <https://docs.docker.com/engine/manage-resources/contexts/
    '';
  };

  config.home.file = builtins.listToAttrs (
    map (s: {
      name = "${cfg.configDir}/contexts/meta/${builtins.hashString "sha256" s.Name}/meta.json";
      value = {
        source = jsonFormat.generate "config.json" s;
      };
    }) cfg.contexts
  );
}
