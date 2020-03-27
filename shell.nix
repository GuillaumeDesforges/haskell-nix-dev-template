let
  # Haskell Nix Dev Template config
  config = import ./nix/config.nix;
  inherit (config) ghc-version use-pinned-nixpkgs pinned-nixpkgs-url pinned-nixpkgs-ref pinned-nixpkgs-rev;
  
  # Nixpkgs
  pkgs = 
    import ./nix/nixpkgs.nix {
      usePinnedNixpkgs = use-pinned-nixpkgs;
      pinnedNixpkgsUrl = pinned-nixpkgs-url;
      pinnedNixpkgsRef = pinned-nixpkgs-ref;
      pinnedNixpkgsRev = pinned-nixpkgs-rev;
    } {
      config = {
        packageOverrides = superpkgs: rec {
          # Haskell GHC version happens here
          haskellPackages = (superpkgs.lib.attrsets.getAttr ghc-version superpkgs.haskell.packages).override {
            overrides = self: super: (import ./nix/extra-deps.nix) super;
          };
        };
      };
    };
  
  # IDEs to chose from
  inherit (config) ide;
  use-ghcide = ide == "ghcide";
  use-hie = ide == "hie";
  
  ghcide = pkgs.lib.attrsets.getAttr ("ghcide-" + ghc-version) (import ./nix/ghcide.nix);
  hie = import ./nix/hie.nix { inherit ghc-version; };

  # Haskell package set with the right version (see override above)
  haskellPackages = pkgs.haskellPackages;

  # Project loaded with `callCabal2nix`
  packages-from-cabal = import ./nix/from-cabal.nix { inherit (haskellPackages) callCabal2nix; };

in
  # Environment with Haskell development env
  (
    haskellPackages.shellFor {
      packages = p: packages-from-cabal;

      buildInputs = [
          haskellPackages.cabal-install
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
  
