{ writeScriptBin }:
{ }:
writeScriptBin "run-virtiofsd" ''
  virtiofsd --shared-dir /mnt --socket-path /tmp/vfsd.sock --log-level debug --sandbox none --announce-submounts
''
