{ pkgs, ... }: {
  home.packages = [
    (pkgs.aspellWithDicts (d: [
      d.en
    ]))
  ];
}
