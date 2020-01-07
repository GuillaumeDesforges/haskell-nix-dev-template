# selector:
#   * Function to select HIE ghc versions. See here https://github.com/Infinisil/all-hies#declarative-installation-nixos-home-manager-or-similar
#   * Example: p: { inherit (p) ghc865; }
{ selector }:
let
  # HIE from all-hies (use Cachix !)
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in
  all-hies.selection { inherit selector; }