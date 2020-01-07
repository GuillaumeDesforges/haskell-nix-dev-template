{ useGhcide ? true
, useHie ? false}:

let
  pkgs = import ./nix/nixpkgs.nix { };

  # ==========================================================================

  # GHC version selector
  ghc-selector = p: p.ghc865;

  # IDEs to chose from
  # TODO refactor the GHC version choice
  hie = import ./nix/hie.nix { selector = (p: {inherit (p) ghc865; }); };
  ghcide = (import ./nix/ghcide.nix).ghcide-ghc865;

  ## =========================================================================

  # Haskell package set with ghcWithPackages changed to always add Hoogle
  haskellPackages-withHoogle = ((ghc-selector pkgs.haskell.packages).override {
    overrides = (self: super:
      {
        ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
        ghcWithPackages = self.ghc.withPackages;
      }
    );
  });

  # Project loaded with `callCabal2nix`
  packages-from-cabal = import ./nix/from-cabal.nix { haskellPackages = haskellPackages-withHoogle; };

in
  # Create Haskell env from projects
  (haskellPackages-withHoogle.ghcWithHoogle (hp: packages-from-cabal)).env
  # Overrie the project environment for development
  .overrideAttrs (oldAttrs:
    let
      NIX_GHC_DOCDIR =
        let
          # helper functions
          reverse = builtins.sort (e1: e2: true);
          all-but-last = l: reverse (builtins.tail (reverse l));
          # first element is empty string after split, last element is "html" to remove
          split-path = path: all-but-last (builtins.tail (pkgs.lib.strings.splitString "/" path)); 
          correct-path = path: builtins.map (s: if s == "ghc" then "hoogle" else s) path;
          concat-path = path: pkgs.lib.strings.concatMapStrings (s: "/${s}") path;
        in
          concat-path (correct-path (split-path oldAttrs.NIX_GHC_DOCDIR));
    in
      {
        # Add HIE and required system packages for development
        buildInputs = oldAttrs.buildInputs 
          ++ (pkgs.lib.lists.optionals useHie    [ hie pkgs.cabal-install ])
          ++ (pkgs.lib.lists.optional  useGhcide ghcide);

        # See https://github.com/NixOS/nixpkgs/issues/76837
        # TODO remove and check after https://github.com/NixOS/nixpkgs/pull/76842 is merged
        # inherit NIX_GHC_DOCDIR;
      }
      // pkgs.lib.attrsets.optionalAttrs useHie {
        # HIE_HOOGLE_DATABASE = NIX_GHC_DOCDIR + "/default.hoo";
      }
  )