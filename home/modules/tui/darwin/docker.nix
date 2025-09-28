{ config, ... }:
{
  programs.docker-cli.settings.currentContext = "colima";
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
    {
      Name = "colima";
      Metadata = {
        Description = "vz based VM containers via colima";
      };
      Endpoints = {
        docker = {
          Host = "unix:///var/lib/colima/.colima/default/docker.sock";
          SkipTLSVerify = false;
        };
      };
    }
  ];
}
