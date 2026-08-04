{ snap }:
final: prev: {
  snap = snap.packages.${prev.stdenv.hostPlatform.system}.default;
}
