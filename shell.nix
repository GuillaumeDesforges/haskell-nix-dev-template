let
  pkgs = import ./nix/nixpkgs.nix { };
  config = import ./nix/config.nix;

  # GHC version
  inherit (config) ghc-version;
  ghc-selector = p: pkgs.lib.attrsets.getAttr ghc-version p;

  # IDEs to chose from
  inherit (config) use-ghcide use-hie;
  ghcide = pkgs.lib.attrsets.getAttr ("ghcide-" + ghc-version) (import ./nix/ghcide.nix);
  hie = import ./nix/hie.nix { selector = ghc-selector; };

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
  packages-from-cabal = import ./nix/from-cabal.nix { haskellPackages = pkgs.haskellPackages; };

in
  # Environment with Haskell development env
  (
    pkgs.haskellPackages.shellFor {
      packages = p: packages-from-cabal;

      buildInputs = [
          haskellPackages-withHoogle.cabal-install
      ]
        ++ (pkgs.lib.lists.optionals use-hie [ hie pkgs.cabal-install ])
        ++ (pkgs.lib.lists.optionals use-ghcide [ ghcide ]);

      withHoogle = true;
    }
  )

  # Some corrections on the shellFor derivation
  .overrideAttrs (oldAttrs:

    let
      # See https://github.com/NixOS/nixpkgs/issues/76837
      # TODO remove and check after https://github.com/NixOS/nixpkgs/pull/76842 is merged and pinned nixpkgs is changed
      NIX_GHC_DOCDIR =
        let
          # helper functions
          reverse = builtins.sort (e1: e2: true);
          all-but-last = l: reverse (builtins.tail (reverse l));
          # first element is empty string after split, last element is "html" to remove
          split-path = path: all-but-last (builtins.tail (pkgs.lib.strings.splitString "/" path)); 
          ghc-to-hoogle = path: builtins.map (s: if s == "ghc" then "hoogle" else s) path;
          concat-path = path: pkgs.lib.strings.concatMapStrings (s: "/${s}") path;
          correct-ghc-docdir-path = path: concat-path (ghc-to-hoogle (split-path path));
        in
          correct-ghc-docdir-path oldAttrs.NIX_GHC_DOCDIR;

    in
      # Correction, see above
      {
        inherit NIX_GHC_DOCDIR;
      }

      # Optional attributes for HIE
      // pkgs.lib.attrsets.optionalAttrs use-hie {
        # Allows HIE to find the hoogle database properly
        HIE_HOOGLE_DATABASE = NIX_GHC_DOCDIR + "/default.hoo";
      }
  )
  
