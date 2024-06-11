{ stdenv
, lib
, callPackage
, buildPackages
,
}: { src
   , configfile
   , modDirVersion
   , version
   , enableGdb ? false
   , kernelPatches ? [ ]
   , nixpkgs
   }:
let
  kernel =
    ((callPackage "${nixpkgs}/pkgs/os-specific/linux/kernel/manual-config.nix" { })
      {
        inherit src modDirVersion version kernelPatches configfile;
        inherit lib stdenv;

        # Because allowedImportFromDerivation is not enabled,
        # the function cannot set anything based on the configfile. These settings do not
        # actually change the .config but let the kernel derivation know what can be built.
        # See manual-config.nix for other options
        config = {
          # Enables the dev build
          CONFIG_MODULES = "y";
        };
      }).overrideAttrs (old: {
      dontStrip = true;
   });

  kernelPassthru = {
    inherit (configfile) structuredConfig;
    inherit modDirVersion configfile;
    passthru = kernel.passthru // (removeAttrs kernelPassthru [ "passthru" ]);
  };
in
lib.extendDerivation true kernelPassthru kernel
