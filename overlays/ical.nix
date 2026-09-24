_:
(_final: prev:
let
  inherit (prev) lib;

  version = "0.12.2";
  commit = "f487d52";
  date = "2026-07-29T08:11:58Z";
in
{
  ical = prev.buildGoModule (finalAttrs: {
    pname = "ical";
    inherit version;

    src = prev.fetchFromGitHub {
      owner = "BRO3886";
      repo = "ical";
      tag = "v${finalAttrs.version}";
      hash = "sha256-APmqU3yqiA08RH/5ED220Q3yZIQ2zFURbDEsf0xpt38=";
    };

    vendorHash = "sha256-an2RZmzdfL2wz3tE/4w1hGTmihaai0C33E9R/tMAa5c=";

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
})
