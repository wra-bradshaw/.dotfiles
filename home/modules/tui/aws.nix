{ pkgs, ... }:
{
  programs.granted = {
    enable = true;
    enableZshIntegration = true;
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
      "profile personal-juiced" = {
        sso_session = "personal";
        sso_account_id = "301436506805";
        sso_role_name = "AdministratorAccess";
      };
      "profile personal-shufflepuck" = {
        sso_session = "personal";
        sso_account_id = "182399685701";
        sso_role_name = "AdministratorAccess";
      };
      "profile personal-valleyfield" = {
        sso_session = "personal";
        sso_account_id = "381492167517";
        sso_role_name = "AdministratorAccess";
      };
      "sso-session personal" = {
        sso_start_url = "https://will-lol.awsapps.com/start";
        sso_region = "ap-southeast-2";
        sso_registration_scopes = "sso:account:access";
      };
    };
  };
}
