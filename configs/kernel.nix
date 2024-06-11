{
  pkgs,
  lib ? pkgs.lib,
  enableGdb ? false,
  linuxSrc,
}:
let
  version = "6.6.0";
  localVersion = "-ethan-development";
in
{
  kernelArgs = {
    inherit enableGdb;

    inherit version;
    src = linuxSrc;

    inherit localVersion;
    modDirVersion = version + localVersion;
  };

  kernelConfig = {
    # See https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/kernel_config.nix
    structuredExtraConfig = with lib.kernel;
      {
        DEBUG_FS = yes;
        DEBUG_KERNEL = yes;
        DEBUG_MISC = yes;
        DEBUG_BUGVERBOSE = yes;
        DEBUG_BOOT_PARAMS = yes;
        DEBUG_STACK_USAGE = yes;
        DEBUG_SHIRQ = yes;
        DEBUG_ATOMIC_SLEEP = yes;

        IKCONFIG = yes;
        IKCONFIG_PROC = yes;
        # Compile with headers
        IKHEADERS = yes;

        SLUB_DEBUG = yes;
        DEBUG_MEMORY_INIT = yes;
        KASAN = yes;

        # FRAME_WARN - warn at build time for stack frames larger tahn this.

        MAGIC_SYSRQ = yes;

        LOCALVERSION = freeform localVersion;

        LOCK_STAT = yes;
        PROVE_LOCKING = yes;

        FTRACE = yes;
        STACKTRACE = yes;
        IRQSOFF_TRACER = yes;

        KGDB = yes;
        UBSAN = yes;
        BUG_ON_DATA_CORRUPTION = yes;
        SCHED_STACK_END_CHECK = yes;
        UNWINDER_FRAME_POINTER = yes;
        "64BIT" = yes;

        # initramfs/initrd ssupport
        BLK_DEV_INITRD = yes;

        PRINTK = yes;
        PRINTK_TIME = yes;
        EARLY_PRINTK = yes;

        # Support elf and #! scripts
        BINFMT_ELF = yes;
        BINFMT_SCRIPT = yes;

        # Create a tmpfs/ramfs early at bootup.
        DEVTMPFS = yes;
        DEVTMPFS_MOUNT = yes;

        TTY = yes;
        SERIAL_8250 = yes;
        SERIAL_8250_CONSOLE = yes;

        PROC_FS = yes;
        SYSFS = yes;

        MODULES = yes;
        MODULE_UNLOAD = yes;

        # virtio
        VIRTIO = yes;

        # HAVE_PCI = yes;
        # PCI = yes;
        # VIRTIO_PCI_LIB = yes;
        # VIRTIO_BALLOON = yes;
        # VIRTIO_NET = yes;
        BLOCK = yes;
        SCSI_LOWLEVEL = yes;
        SCSI = yes;
        SCSI_VIRTIO = yes;
        BLK_DEV_SD = yes;

        OVERLAY_FS = yes;

        # virtiofs support
        DAX = yes;
        FS_DAX = yes;
        MEMORY_HOTPLUG = yes;
        MEMORY_HOTREMOVE = yes;
        ZONE_DEVICE = yes;
        FUSE_FS = yes;
        VIRTIO_FS = yes;
      }
      // lib.optionalAttrs enableGdb {
        DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = yes;
        GDB_SCRIPTS = yes;
      };

    # Flags that get passed to generate-config.pl
    generateConfigFlags = {
      # Ignores any config errors (eg unused config options)
      ignoreConfigErrors = false;
      # Build every available module
      autoModules = false;
      preferBuiltin = false;
    };
  };
}
