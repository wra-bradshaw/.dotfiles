{ ... }:
(final: prev: {
  glide =
    let
      rev = "7d1f2c16be8f4beea96942c5823331a55233b36f";
      shortHash = prev.lib.substring 0 7 rev;
      pversion = "main-${shortHash}";
    in
    prev.rustPlatform.buildRustPackage (finalAttrs: {
      pname = "glide";
      version = pversion;

      src = prev.fetchFromGitHub {
        owner = "glide-wm";
        repo = "glide";
        inherit rev;
        sha256 = "sha256-p9unwYgNzhQVvQKTnc3/EhG9te6X4lzCMEUC+bNrfiE=";
      };

      cargoHash = "sha256-E0SrvvAfJmIVYjZv9htxR/VoQyO0MdDFSWZ04tO0g1Y=";

      nativeBuildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
        prev.imagemagick
        prev.libicns # Provides png2icns
        (prev.writeShellScriptBin "sw_vers" ''
          echo 'ProductVersion: ${prev.stdenv.hostPlatform.darwinMinVersion}'
        '')
      ];

      doInstallCheck = false;
      doCheck = false;

      postInstall = ''
        # Create a simple .app bundle on the fly
        mkdir -p $out/Applications/Glide.app/Contents/{MacOS,Resources}

        cp $out/bin/glide $out/Applications/Glide.app/Contents/MacOS/glide
        cp $out/bin/glide_server $out/Applications/Glide.app/Contents/MacOS/glide_server

        # Generate .icns from PNG using libicns
        ICONDIR=$(mktemp -d)
        SRC_ICON=${finalAttrs.src}/assets/app_icon-128x128@2x.png

        # Generate icon sizes for png2icns
        # png2icns expects specific sizes
        for size in 16 32 48 128 256 512; do
          magick "$SRC_ICON" -resize ''${size}x''${size} "$ICONDIR/icon_''${size}x''${size}.png"
        done

        # Create .icns file from PNGs
        png2icns $out/Applications/Glide.app/Contents/Resources/Glide.icns "$ICONDIR"/icon_*.png

        cat > $out/Applications/Glide.app/Contents/Info.plist <<EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
          "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>English</string>

          <key>CFBundleDisplayName</key>
          <string>Glide</string>

          <key>CFBundleExecutable</key>
          <string>glide_server</string>

          <key>CFBundleIconFile</key>
          <string>Glide</string>

          <key>CFBundleIdentifier</key>
          <string>org.glidewm.glide</string>

          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>

          <key>CFBundleName</key>
          <string>Glide</string>

          <key>CFBundlePackageType</key>
          <string>APPL</string>

          <key>CFBundleVersion</key>
          <string>${finalAttrs.version}</string>

          <key>CSResourcesFileMapped</key>
          <true/>

          <key>LSRequiresCarbon</key>
          <true/>

          <key>NSHighResolutionCapable</key>
          <true/>

          <key>LSUIElement</key>
          <true/>

          <key>NSAppleEventsUsageDescription</key>
          <string>Glide needs to manage and rearrange windows.</string>

          <key>NSAccessibilityUsageDescription</key>
          <string>Glide needs accessibility access to manage windows.</string>
        </dict>
        </plist>
        EOF

        echo "✅ Glide.app bundle created at $out/Applications/Glide.app"
      '';

      passthru = {
        updateScript = prev.nix-update-script { };
      };

      meta = with prev.lib; {
        platforms = platforms.darwin;
        mainProgram = "glide";
      };
    });
})
