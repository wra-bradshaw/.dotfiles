{ ... }:
{
  programs.awscli = {
    settings = {
      "sso-session ionata" = {
        sso_start_url = "https://ionata.awsapps.com/start";
        sso_region = "ap-southeast-2";
        sso_registration_scopes = "sso:account:access";
        granted_color = "red";
      };
      "profile ionata-development" = {
        sso_session = "ionata";
        sso_account_id = "595976489491";
        sso_role_name = "DeveloperAccess";
        granted_color = "red";
      };
      "profile ionata-ses" = {
        sso_session = "ionata";
        sso_account_id = "654654613657";
        sso_role_name = "DeveloperAccess";
        granted_color = "red";
      };
      "profile ionata-dpfemfire" = {
        sso_session = "ionata";
        sso_account_id = "832039930341";
        sso_role_name = "DeveloperAccess";
        granted_color = "red";
      };
      "profile ionata" = {
        sso_session = "ionata";
        sso_account_id = "616986483443";
        sso_role_name = "DeveloperAccess";
      };
    };
  };
}
