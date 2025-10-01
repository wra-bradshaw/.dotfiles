{ pkgs }:

{
  width,
  height,
  color,
}:
let
  w = toString width;
  h = toString height;

  # Keep the output name readable/stable
  sanitize =
    s:
    builtins.replaceStrings
      [
        "#"
        " "
        "/"
        ":"
        "("
        ")"
        ","
        "["
        "]"
      ]
      [
        ""
        "-"
        "-"
        "-"
        ""
        ""
        "-"
        ""
        ""
      ]
      s;

  name = "solid-${w}x${h}-${sanitize color}.png";
in
assert builtins.isInt width && width > 0;
assert builtins.isInt height && height > 0;
pkgs.runCommand name { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
  set -euo pipefail
  ${pkgs.imagemagick}/bin/magick -size ${w}x${h} "xc:${color}" "png:$out"
''
