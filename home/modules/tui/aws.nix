{ pkgs, ... }:
{
  programs.granted = {
    # enable = true;
    # enableZshIntegration = true;
  };

  programs.awscli = {
    enable = true;
    package = (
      pkgs.awscli2.overrideAttrs (old: {
        makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
          "--unset"
          "PYTHONPATH"
        ];
      })
    );
    settings = {
      "profile personal-william-bradshaw" = {
        sso_session = "personal";
        sso_account_id = "301436506805";
        sso_role_name = "AdministratorAccess";
        granted_color = "green";
      };
      "sso-session personal" = {
        sso_start_url = "https://will-lol.awsapps.com/start";
        sso_region = "ap-southeast-2";
        sso_registration_scopes = "sso:account:access";
      };
    };
  };
}
