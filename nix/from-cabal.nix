{ haskellPackages }:
let
  pkgs = import ./nixpkgs.nix;

  # From https://github.com/fghibellini/nix-haskell-monorepo/blob/master/monorepo-nix-expressions/monorepo/nix/lib/utils.nix
  findHaskellPackages = root:
    let
      items = builtins.readDir root;
      fn = file: type:
        if type == "directory" && isNull (builtins.match "\\..*" file) && !(builtins.elem file ["dist" "dist-new"]) then (findHaskellPackages (root + (/. + file)))
        else (if type == "regular" then (let m = (builtins.match "(.*)\\.cabal" file); in if !(isNull m) then { "${builtins.elemAt m 0}" = root; } else {}) else {});
    in
      builtins.foldl' (x: y: x // y) {} (builtins.attrValues (builtins.mapAttrs fn items));
  
  found-packages = findHaskellPackages ./../packages;

  called-packages = builtins.attrValues (builtins.mapAttrs (name: value: haskellPackages.callPackage value) found-packages);

in
  called-packages