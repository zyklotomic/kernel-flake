{
  description = "A very basic flake for Linux kernel development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    linuxSrc = {
      url = "git+file:../../linux-trees/linux-nix-worktree?shallow=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    linuxSrc,
  }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    buildLib = pkgs.callPackage ./build { };

    linuxConfigs = pkgs.callPackage ./configs/kernel.nix { inherit linuxSrc; };
    inherit (linuxConfigs) kernelArgs kernelConfig;

    # Config file derivation
    configfile = buildLib.buildKernelConfig {
      inherit
        (kernelConfig)
        generateConfigFlags
        structuredExtraConfig
        ;
      inherit kernel nixpkgs;
    };

    # Kernel derivation
    kernelDrv = buildLib.buildKernel {
      inherit
        (kernelArgs)
        src
        modDirVersion
        version
        enableGdb
        ;

      inherit configfile nixpkgs;
    };

    # linuxDev = pkgs.linuxPackagesFor kernelDrv;
    linuxDev = pkgs.linuxPackages_latest;
    kernel = linuxDev.kernel;

    initramfs = buildLib.buildInitramfs {
      inherit kernel;

      modules = [ kernel ];

      extraBin =
        {
          strace = "${pkgs.strace}/bin/strace";
        };
      storePaths = [ pkgs.foot.terminfo ];
    };

    runQemu = buildLib.buildQemuCmd {
      inherit kernel initramfs;
      inherit (kernelArgs) enableGdb;
    };

    runVirtiofsd = buildLib.buildVirtiofsdCmd {};

    devShell =
      let
        nativeBuildInputs = with pkgs;
          [
            bear # for compile_commands.json, use bear -- make
            runQemu
            runVirtiofsd
            git
            gdb
            qemu
            pahole
            flex
            bison
            bc
            pkg-config
            elfutils
            openssl.dev
            llvmPackages.clang
            (python3.withPackages (ps: with ps; [
              GitPython
              ply
            ]))
            codespell
            virtiofsd

            # static analysis
            flawfinder
            cppcheck
            sparse

          ];
        buildInputs = [ pkgs.nukeReferences kernel.dev ];
      in
        pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
          KERNEL = kernel.dev;
          KERNEL_VERSION = kernel.modDirVersion;
        };
  in
  {
    lib = {
      builders = import ./build/default.nix;
    };

    packages.${system} = {
      inherit initramfs kernel;
      kernelConfig = configfile;
    };

    devShells.${system}.default = devShell;
  };
}
