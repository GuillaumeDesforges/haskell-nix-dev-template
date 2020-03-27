{ usePinnedNixpkgs
, pinnedNixpkgsUrl ? "https://github.com/nixos/nixpkgs-channels/"
, pinnedNixpkgsRef ? "refs/heads/nixos-19.09"
, pinnedNixpkgsRev ? "107ffbb22ad7920cb3c694dcc1d032a39e003b14"
}:

# The version of nixpkgs used for this project
let
  # Either a pinned version
  pinned-nixpkgs =
    import (
      builtins.fetchGit {
        url = pinnedNixpkgsUrl;
        ref = pinnedNixpkgsRef;
        rev = pinnedNixpkgsRev;
      }
    );
  
  # Or the current local
  current-local = import <nixpkgs>;
in
  if usePinnedNixpkgs then pinned-nixpkgs else current-local