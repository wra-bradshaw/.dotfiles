_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = { };
      "ssh.github.com" = {
        ForwardAgent = true;
        Port = 443;
      };
      "github.com" = {
        HostName = "ssh.github.com";
        ForwardAgent = true;
        Port = 443;
      };
      "stage" = {
        HostName = "q.dev.ionata.com";
        ForwardAgent = true;
      };
    };
  };
}
