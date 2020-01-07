let
  pkgs = import ./nix/nixpkgs.nix;
in
  pkgs.haskellPackages.callPackage (import ./nix/from-cabal.nix) {}