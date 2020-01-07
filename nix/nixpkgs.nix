# The version of nixpkgs used for this project
let
  # Either a pinned version
  get-pinned-nixpkgs = rev: 
    builtins.fetchGit {
        url = "https://github.com/NixOS/nixpkgs.git";
        ref = "master";
        inherit rev;
    };
  # pinned-nixpkgs = get-pinned-nixpkgs "cca0c894a13ec398de8b046174239513197f5c74"
  
  # Or the current local
  current-local = import <nixpkgs>;
in
  current-local