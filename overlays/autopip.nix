{ ... }:
(final: prev: {
  autopip = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "autopip";
    version = "0.4";
    src = prev.fetchurl {
      url = "https://github.com/vordenken/AutoPiP/releases/download/v${finalAttrs.version}/AutoPiP.dmg";
      hash = "sha256-tXbK6+8nHqLYB9XS9BPSLAJtqpdhCAWFWh2+Dm3k9B0=";
    };
    nativeBuildInputs = [
      prev.gnugrep
      prev.coreutils
      prev.gawk
      prev.darwin.ditto
    ];
    unpackPhase = ''
      mount_output=$(/usr/bin/hdiutil attach -readonly -nobrowse -mountrandom /tmp $src)
      echo "hdiutil attach output:"
      echo "$mount_output"

      mount_point=$(echo "$mount_output" | grep -o '/private/tmp/dmg\.[^[:space:]]*' | tail -n1)

      ditto "$mount_point/AutoPiP.app" "./AutoPiP.app"

      /usr/bin/hdiutil detach "$mount_point"
    '';
    dontPatchShebangs = true;
    installPhase = ''
      runHook preInstall

      ls
      mkdir -p "$out/Applications"
      ditto "AutoPiP.app" "$out/Applications/AutoPiP.app"

      runHook postInstall
    '';
  });
})
