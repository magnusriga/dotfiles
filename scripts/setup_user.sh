#!/usr/bin/env bash

echo "Running setup_user.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

SCRIPTPATH="$( cd -- "$(dirname "$BASH_SOURCE")" >/dev/null 2>&1 ; pwd -P )/"

echo "SCRIPTPATH is $SCRIPTPATH."

# New user details.
export USERNAME="nfu"
export USER_UID="1000"
export USER_GID=$USER_UID
GROUPNAME=$USERNAME
PASSWORD=$USERNAME

export CURRENT_USER=$(whoami)

SHELL=$(which bash)

# Create new user.
if ! grep -iFq $USERNAME /etc/passwd; then
  echo "User $USERNAME did not exist, adding a new user with username $USERNAME, password $USERNAME, and UID:GID $USER_UID:$USER_GID."
  sudo groupadd -g $USER_GID $GROUPNAME
  sudo useradd -m -g $GROUPNAME -s $SHELL -u $USER_UID $USERNAME
  echo $USERNAME:$USERNAME | sudo chpasswd 
fi

# Update sudoers file.
if [ ! -e "/etc/sudoers.d/$USERNAME" ] || ! sudo grep -iFq "User_Alias NEW_ADMIN" "/etc/sudoers.d/$USERNAME"; then
  echo "/etc/sudoers.d/$USERNAME did not exist, or the file did not contain the right alias, adding NEW_ADMIN User_Alias to: /etc/sudoers.d/$USERNAME"
  echo -e "User_Alias NEW_ADMIN = #$USER_UID, %#$USER_GID, $USERNAME, %$USERNAME : NEW_FULLTIMERS = $USERNAME, %$USERNAME\n\
  NEW_ADMIN, NEW_FULLTIMERS ALL = (ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USERNAME" 1> /dev/null
fi
