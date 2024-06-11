{
  lib,
  writeScriptBin,
}: { kernel
   , initramfs
   , memory ? "2G"
   , enableGdb ? false
   ,
   }:
writeScriptBin "runvm" ''
  sudo qemu-system-x86_64 \
    -enable-kvm \
    -m ${memory} \
    -kernel ${kernel}/bzImage \
    -initrd ${initramfs}/initrd.gz \
    -nographic -append "console=ttyS0" \
    -chardev socket,id=char0,path=/tmp/vfsd.sock \
    -device vhost-user-fs-pci,queue-size=1024,chardev=char0,tag=myfs \
    -object memory-backend-memfd,id=mem,size=${memory},share=on \
    -numa node,memdev=mem \
    ${lib.optionalString enableGdb "-s"}
''
