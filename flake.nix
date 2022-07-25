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
      in
      {
        oblonsky = pkgs.stdenv.mkDerivation {
          name = "home"; # our package name, irrelevant in this case
          src = ./.;
          buildPhase = ''
            ${pkgs.hugo}/bin/hugo --minify
          '';
          installPhase = ''
            cp -r public $out
          '';
          meta = with pkgs.lib; {
            description = "obl0nsky";
            license = licenses.cc-by-nc-sa-40;
            platforms = platforms.all;
          };
        };
        packages.default = rt;

        apps.default = flake-utils.lib.mkApp {
          drv = oblonsky;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks;

          buildInputs = [
            pkgs.hugo
          ];
        };
      });
}
