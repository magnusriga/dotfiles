Host orb
  Hostname 127.0.0.1
  Port 32222
  User nfu
  ForwardAgent yes
  # replace or symlink ~/.orbstack/ssh/id_ed25519 file to change the key
  # IdentityFile ~/.orbstack/ssh/id_ed25519
  # # Only use this key.
  # IdentitiesOnly yes
  ProxyCommand '/Applications/OrbStack.app/Contents/Frameworks/OrbStack Helper.app/Contents/MacOS/OrbStack Helper' ssh-proxy-fdpass 501
  ProxyUseFdpass yes
