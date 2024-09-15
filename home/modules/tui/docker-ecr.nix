{ pkgs, ... }:
{
  home.packages = [ pkgs.amazon-ecr-credential-helper ];
  home.file =
    if !pkgs.stdenv.isDarwin then
      {
        ".docker/config.json".text = ''
          {
            "credsStore": "ecr-login"
          }
        '';
      }
    else
      { };
}
