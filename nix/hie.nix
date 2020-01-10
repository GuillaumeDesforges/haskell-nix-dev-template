# selector:
#   * Function to select HIE ghc versions. See here https://github.com/Infinisil/all-hies#declarative-installation-nixos-home-manager-or-similar
#   * Example: p: { inherit (p) ghc865; }
{ ghc-version }:
let
  # HIE from all-hies (use Cachix !)
  all-hies-rev = "master";
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/${all-hies-rev}") {};
in
  all-hies.selection { selector = p: { "${ghc-version}" = builtins.getAttr ghc-version p; }; }