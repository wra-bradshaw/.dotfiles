_:
(
  _final: prev:
  let
    inherit (prev) lib;

    version = "0.13.1";
    commit = "d75e817";
    date = "2026-10-28T11:00:32Z";
  in
  {
    ical = prev.buildGoModule (finalAttrs: {
      pname = "ical";
      inherit version;

      src = prev.fetchFromGitHub {
        owner = "BRO3886";
        repo = "ical";
        tag = "v${finalAttrs.version}";
        hash = "sha256-k9TL/l/UWoF/Gcn5T+wJrtQsoLwc+pfTfjPiexsm3MY=";
      };

      vendorHash = "sha256-0RpCUpExlbZS5UIjdWlPteyLqE2Ff0cH3MnT4Et+Us4=";

      ldflags = [
        "-X main.version=v${version}"
        "-X main.commit=${commit}"
        "-X main.date=${date}"
      ];

      meta = {
        description = "Fast native macOS Calendar CLI built on EventKit";
        homepage = "https://ical.sidv.dev";
        license = lib.licenses.mit;
        mainProgram = "ical";
        platforms = lib.platforms.darwin;
      };
    });
  }
)
