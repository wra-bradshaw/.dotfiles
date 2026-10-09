_: {
  programs.lazygit = {
    enable = true;
    settings = {
      git.overrideGpg = true;
      os.editPreset = "nvim";
      quitOnTopLevelReturn = true;
    };
  };
}
