_:
(_final: prev: {
  git-credential-manager =
    if prev.stdenv.hostPlatform.isDarwin then
      prev.git-credential-manager.override {
        dotnetCorePackages = prev.dotnetCorePackages // {
          sdk_10_0 = prev.dotnetCorePackages.sdk_10_0-bin;
          runtime_10_0 = prev.dotnetCorePackages.runtime_10_0-bin;
        };
      }
    else
      prev.git-credential-manager;
})
