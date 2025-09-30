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
    type = lib.types.attrsOf (
      lib.types.submodule {
        freeformType = jsonFormat.type;
      }
    );
    default = { };
    example = lib.literalExpression ''
      {
        example = {
          Metadata = { Description = "example1"; };
          Endpoints.docker.Host = "unix://example2";
        };
      }
    '';
    description = ''
      Attrset of docker context configurations keyed by context name. See:
      <https://docs.docker.com/engine/manage-resources/contexts/
    '';
  };

  config.home.file = lib.mapAttrs' (
    n: ctx:
    let
      name = if ctx ? Name then ctx.Name else n;
      path = "${cfg.configDir}/contexts/meta/${builtins.hashString "sha256" name}/meta.json";
    in
    {
      name = path;
      value = {
        source = jsonFormat.generate "config.json" (ctx // { Name = name; });
      };
    }
  ) cfg.contexts;
}
