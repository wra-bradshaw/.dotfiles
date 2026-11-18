_:
(_final: prev: {
  rex-app = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "rex";
    version = "0.1.0";
    build = "2042";

    # The versioned URL comes from the Sparkle feed the app ships with
    # (SUFeedURL in Info.plist); `latest.dmg` currently serves this same file.
    src = prev.fetchurl {
      url = "https://blob.superlogical.com/public/rex-app/preview/Rex-${finalAttrs.version}-${finalAttrs.build}.dmg";
      hash = "sha256-Pw+ZqxjvH4p4BYmW/M+pD1XOZZDmjhV5ckQaoahJ0ik=";
    };

    nativeBuildInputs = [ prev._7zz ];

    dontStrip = true;

    # The shipped Sparkle.framework contains a dangling
    # `XPCServices -> Versions/Current/XPCServices` link; Sparkle ships no
    # XPCServices directory in this build, so the fixup check must be skipped.
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
