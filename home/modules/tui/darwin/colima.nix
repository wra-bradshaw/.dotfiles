{ config, ... }:
{
  services.colima = {
    enable = true;
    profiles = {
      default = {
        isActive = true;
        isService = true;
      };
    };
  };
}
