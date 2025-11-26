{ ... }:
(final: prev: {
  rimage = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "rimage";
    version = "0.12.1";

    src = prev.fetchFromGitHub {
      owner = "SalOne22";
      repo = "rimage";
      tag = "v${finalAttrs.version}";
      hash = "sha256-ujoWQcOeX0WpzHHaxEu/39s7LtAqC9QRsrhioLs+few=";
    };

    cargoHash = "sha256-tsASNZaRZblzah+FqA8/82WeZ7yDpbokaVs9Mo7mI6w=";

    cargoBuildFlags = [
      "--features"
      "build-binary,threads,metadata,resize,quantization,mozjpeg,oxipng,webp,avif,tiff,icc,console"
    ];

    nativeBuildInputs = [
      prev.cmake
      prev.perl
    ];
  });
})
