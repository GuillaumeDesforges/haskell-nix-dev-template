{ usePinnedNixpkgs ? false }:
# The version of nixpkgs used for this project
let
  # Either a pinned version
  get-pinned-nixpkgs = ref: rev:
    builtins.fetchGit {
        url = "https://github.com/NixOS/nixpkgs.git";
        inherit ref rev;
    };
  pinned-nixpkgs = get-pinned-nixpkgs "master" "cca0c894a13ec398de8b046174239513197f5c74" {};
  
  # Or the current local
  current-local = import <nixpkgs> {};
in
  if usePinnedNixpkgs then pinned-nixpkgs else current-local