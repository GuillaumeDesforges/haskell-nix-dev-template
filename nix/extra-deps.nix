let
    # Add package function to be called by `buildPackages`

    # Example from https://github.com/fghibellini/nix-haskell-monorepo/tree/master/extra-deps
    # feel free to remove from project
    http2-grpc-types = 
        { mkDerivation, base, binary, bytestring, case-insensitive, fetchgit, hpack, proto-lens, stdenv, zlib }:
        mkDerivation {
            pname = "http2-grpc-types";
            version = "0.3.0.1";
            src = fetchgit {
                url = "https://github.com/lucasdicioccio/http2-grpc-types.git";
                sha256 = "08ni3cl9q3va0sr81dahn17g9wf8fn6srp6nsnvpzrfrp3myfsym";
                rev = "ea6cd15b9929494e05e0ffb37aedccf915717020";
                fetchSubmodules = true;
            };
            libraryHaskellDepends = [
                base binary bytestring case-insensitive proto-lens zlib
            ];
            libraryToolDepends = [ hpack ];
            preConfigure = "hpack";
            homepage = "https://github.com/lucasdicioccio/http2-grpc-types#readme";
            description = "Types for gRPC over HTTP2 common for client and servers";
            license = stdenv.lib.licenses.bsd3;
        };
in
    (super: {
        # Follow this example :
        http2-grpc-types = super.callPackage http2-grpc-types {};
    })