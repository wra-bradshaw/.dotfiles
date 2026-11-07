_:
(_final: prev: {
  ntn = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "ntn";
    version = "0.23.28";

    # The npm tarball bundles prebuilt (self-contained) binaries for every platform.
    src = prev.fetchurl {
      url = "https://registry.npmjs.org/ntn/-/ntn-${finalAttrs.version}.tgz";
      hash = "sha256-fo4riFgbFvZLX12VujErlRggwGkvGLF7RiroRI1g2RE=";
    };

    nativeBuildInputs = [ prev.installShellFiles ];

    dontBuild = true;
    dontStrip = true;

    platformDir =
      {
        aarch64-darwin = "ntn-darwin-arm64";
        x86_64-darwin = "ntn-darwin-x64";
        aarch64-linux = "ntn-linux-arm64";
        x86_64-linux = "ntn-linux-x64";
      }
      .${prev.stdenv.hostPlatform.system}
        or (throw "ntn: unsupported system ${prev.stdenv.hostPlatform.system}");

    installPhase = ''
      runHook preInstall
      install -Dm755 dist/$platformDir/ntn $out/bin/ntn
      runHook postInstall
    '';

    postInstall = prev.lib.optionalString (prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) ''
      export HOME=$TMPDIR
      installShellCompletion --cmd ntn \
        --bash <($out/bin/ntn completions bash) \
        --fish <($out/bin/ntn completions fish) \
        --zsh <($out/bin/ntn completions zsh)
    '';

    meta = {
      description = "The Notion CLI";
      homepage = "https://developers.notion.com/cli/get-started/overview";
      license = prev.lib.licenses.mit;
      mainProgram = "ntn";
      platforms = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  });
})
