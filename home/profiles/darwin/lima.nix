{ config, ... }:
{
  services.lima = {
    enable = true;
    instances.docker = {
      autostart = true;
      settings = {
        base = [ "template:docker" ];
        vmType = "vz";
        arch = "aarch64";
        cpus = 4;
        memory = "4GiB";
        disk = "100GiB";
        mountType = "virtiofs";
        vmOpts.vz.rosetta = {
          enabled = true;
          binfmt = true;
        };
        mounts = [
          {
            location = config.home.homeDirectory;
            writable = true;
          }
        ];
      };
    };
  };
}
