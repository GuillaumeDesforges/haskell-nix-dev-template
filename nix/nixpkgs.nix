{ usePinnedNixpkgs
, pinnedNixpkgsRef
, pinnedNixpkgsUrl
, pinnedNixpkgsRev
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