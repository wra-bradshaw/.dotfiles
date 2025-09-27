{ config, ... }:
{
  programs.docker-cli.settings.currentContext = "apple-container";
  programs.docker-cli.contexts = [
    {
      Name = "apple-container";
      Metadata = {
        Description = "Apple Native Containers via Socktainer";

      };
      Endpoints = {
        docker = {
          Host = "unix://${config.home.homeDirectory}/.socktainer/container.sock";
          SkipTLSVerify = false;
        };
      };
    }
  ];
}
