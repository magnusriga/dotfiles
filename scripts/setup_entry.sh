#!/usr/bin/env bash

echo "Running setup_entry.sh."

# New user details.
export USERNAME="nfu"
export USER_UID="1000"
export USER_GID=$USER_UID
GROUPNAME=$USERNAME
PASSWORD=$USERNAME

export CURRENT_USER=$(whoami)
echo "CURRENT_USER is $CURRENT_USER"

SHELL=$(which bash)

# Create new user.
if ! grep -iFq $USERNAME /etc/passwd; then
  echo "User $USERNAME did not exist, adding a new user with username $USERNAME, password $USERNAME, and UID:GID $USER_UID:$USER_GID."
  sudo groupadd -g $USER_GID $GROUPNAME
  sudo useradd -m -g $GROUPNAME -s $SHELL -u $USER_UID $USERNAME
  echo $USERNAME:$USERNAME | sudo chpasswd 
if

# Update sudoers file.
if [ ! -e "/etc/sudoers.d/$USERNAME" ] || ! sudo grep -iFq "User_Alias NEW_ADMIN" "/etc/sudoers.d/$USERNAME"; then
  echo "/etc/sudoers.d/$USERNAME did not exist, or the file did not contain the right alias, adding NEW_ADMIN User_Alias to: /etc/sudoers.d/$USERNAME"
  echo -e "User_Alias ADMIN = #$USER_UID, %#$USER_GID, $USERNAME, %$USERNAME : FULLTIMERS = $USERNAME, %$USERNAME\n\
  ADMIN, FULLTIMERS ALL = NOPASSWD: /usr/bin/apt-get, NOPASSWD: /usr/bin/apt" | sudo tee "/etc/sudoers.d/$USERNAME"
fi

# Run remaining setup scripts as new user.
if [ -f "./setup_main.sh" ]; then
  set -a
  sudo -u $USERNAME ./setup_main.sh
  set +a
fi
