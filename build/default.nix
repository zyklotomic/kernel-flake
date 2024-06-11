{ pkgs }: {
  buildInitramfs = pkgs.callPackage ./initramfs.nix {};
  buildKernelConfig = pkgs.callPackage ./kernel-config.nix {};
  buildKernel = pkgs.callPackage ./kernel.nix {};
  buildQemuCmd = pkgs.callPackage ./run-qemu.nix {};
  buildVirtiofsdCmd = pkgs.callPackage ./run-virtiofsd.nix {};
}
