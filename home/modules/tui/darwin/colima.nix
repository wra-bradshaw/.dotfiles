{ ... }:
{
  services.colima = {
    enable = true;
    useAsDefaultContext = true;
    settings = {
      runtime = "docker";
      arch = "aarch64";
      rosetta = true;
    };
  };
}
