_:
(_final: prev: {
  rex-app = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "rex";
    version = "0.1.0";
    build = "2147";

    # The versioned URL comes from the Sparkle feed the app ships with
    # (SUFeedURL in Info.plist); `latest.dmg` currently serves this same file.
    src = prev.fetchurl {
      url = "https://blob.superlogical.com/public/rex-app/preview/Rex-${finalAttrs.version}-${finalAttrs.build}.dmg";
      hash = "sha256-UNTcmw4ZQV4BKzZ+V4zeKx8m1GR1wQNAw8rC5Thh6/8=";
    };

    nativeBuildInputs = [ prev._7zz ];

    dontStrip = true;

    # TODO: Remove workaround: the shipped Sparkle.framework has a dangling XPCServices symlink; drop once a Rex build ships without it
    dontCheckForBrokenSymlinks = true;

    unpackPhase = ''
      runHook preUnpack
      7zz x -snld "$src"
      find . -name '*:com.apple.provenance' -delete
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R "Rex/Rex.app" "$out/Applications/"
      runHook postInstall
    '';

    meta = {
      description = "Rex Beta — Superlogical's terminal workspace";
      homepage = "https://superlogical.com";
      license = prev.lib.licenses.unfree;
      platforms = prev.lib.platforms.darwin;
      sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
    };
  });
})
