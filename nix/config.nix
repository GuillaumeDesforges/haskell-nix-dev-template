{
  # GHC version
  ghc-version = "ghc865";

  # IDEs (either "ghcide" or "hie")
  ide = "ghcide";

  # Whether to use machine <nixpkgs> or a pinned version
  use-pinned-nixpkgs = true;
  # if set to true, set url, ref and revision of pinned nixpkgs
  pinned-nixpkgs-url = https://github.com/nixos/nixpkgs-channels/;
  pinned-nixpkgs-ref = "refs/heads/nixos-19.09";
  pinned-nixpkgs-rev = "107ffbb22ad7920cb3c694dcc1d032a39e003b14";
}