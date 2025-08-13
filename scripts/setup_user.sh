#!/usr/bin/env bash

# =================================================================
# Create new user.
# Must be executed from sudoer user, different from new user,
# as user cannot add itself to sudoers file, if not already there.
# User must be in sudoers file, to add user to sudoers file,
# thus it only makes sense for this script to be run by another user than
# the new user.
# =================================================================

# New user details.
export USERNAME="nfu"

# Check if UID 1000 or GID 1000 exists, if so use 1001 for both
if id -u 1000 >/dev/null 2>&1 || getent group 1000 >/dev/null 2>&1; then
  export USER_UID="1001"
  export USER_GID="1001"
else
  export USER_UID="1000"
  export USER_GID="1000"
fi

GROUPNAME=$USERNAME
PASSWORD=$USERNAME

echo "Running setup_user.sh as $(whoami), with HOME $HOME and USERNAME $USERNAME."

if [ "$(whoami)" == "$USERNAME" ]; then
  echo "This script should be sourced by sudoer user different from new user, now exiting..."
  [ "${BASH_SOURCE[0]}" == "${0}" ] && exit || return
fi

SCRIPTPATH="$(
  cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit
  pwd -P
)/"
echo "SCRIPTPATH is $SCRIPTPATH."

CURRENT_USER=$(whoami)
export CURRENT_USER

SHELL=$(which bash)

# Create new user.
if ! grep -iFq $USERNAME /etc/passwd; then
  echo "User $USERNAME did not exist, adding a new user with username $USERNAME, password $USERNAME, and UID:GID $USER_UID:$USER_GID."
  sudo groupadd -g $USER_GID $GROUPNAME
  sudo useradd -m -g $GROUPNAME -s "$SHELL" -u $USER_UID $USERNAME
  echo $USERNAME:$PASSWORD | sudo chpasswd
fi

# Update sudoers file.
sudo chmod 755 "/etc/sudoers.d"
sudo rm -rf "/etc/sudoers.d/$USERNAME"
if [ ! -e "/etc/sudoers.d/$USERNAME" ] || ! sudo grep -iFq "User_Alias NEW_ADMIN" "/etc/sudoers.d/$USERNAME"; then
  echo "Adding User_Alias NEW_ADMIN and NEW_FULLTIMERS to /etc/sudoers.d/$USERNAME, with NOPASSWD: ALL."
  echo -e "User_Alias NEW_ADMIN = #$USER_UID, %#$USER_GID, $USERNAME, %$USERNAME : NEW_FULLTIMERS = $USERNAME, %$USERNAME\n\nNEW_ADMIN, NEW_FULLTIMERS ALL = (ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USERNAME" 1>/dev/null
fi

# Add user to docker group, to allow running docker commands without sudo.
sudo usermod -aG docker "${USERNAME}"
