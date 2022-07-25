{
  description = "Blog";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        inherit (pkgs) lib;
        my-hugo = pkgs.hugo.overrideAttrs (old:
          {
            meta.broken = false;
          });

        oblonsky = pkgs.stdenv.mkDerivation {
          name = "home"; # our package name, irrelevant in this case
          src = ./.;
          buildPhase = ''
            ${my-hugo}/bin/hugo --minify
          '';
          installPhase = ''
            cp -r public $out
          '';
        };
      in
      {
        packages.default = oblonsky;

        apps.default = flake-utils.lib.mkApp {
          drv = oblonsky;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            my-hugo
          ];
        };
      });
}
