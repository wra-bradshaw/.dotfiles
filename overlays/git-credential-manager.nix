_:
(_final: prev: {
  # TODO: Remove workaround: git-credential-manager 3.x needs the dotnet 10 source-built SDK, which isn't cached for aarch64-darwin and times out CI; drop once cache.nixos.org has dotnet-vmr 10 for aarch64-darwin
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
