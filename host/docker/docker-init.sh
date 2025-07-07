#!/bin/sh

# Note(s):
# - This file is not called from the repo, but instead copied into the container by the Dockerfile, then run as ENTRYPOINT from there.
# - See all users on linux: cat /etc/passwd
#   - username, encrypted password (i.e. if password is stored in /etc/shadow), user ID, group ID, user info, home directory, defualt shell.
# - root user is always: UID 0, GID 0.
# - In tests, i.e. [ ... ], -ne and similar is used for integer comparison, = is used for string comparison. and flag ! negates the condition.
# - Bash commands are separated by space, meaning [1 -ne 0] would start by executing command [1 , which is not an actual command. Instead, add space: [ 1 -ne 0 ].
# - $? is a special variable that holds the exit status of the last executed command. 0 means success, non-zero means failure.
# - $0 is the name of the script, $n is the nth argument to script or funciton, and $@ is all arguments passed to script or function (whichever context we are in).
# - id shows the user and group IDs of the current user, or the user with the specified username, and id -u shows only the user ID.
# - grep [options] pattern [files] searches for pattern in files within the current working directory, and outputs the lines containing the pattern.
# - Wildcards are supported in both pattern and files.
# - grep can search recursively in all files within a directory by using the -r option.
# - If a file is not specified in grep, it reads the file from standard input: cat /etc/group | grep :1001:.
# - -E option in grep enables extended regular expressions, which allows for more complex patterns.
# - /etc/group is a file with format: ubuntu:x:1001:nfu.
#   - group name, encrypted password (blank if no password), group ID, comma-separated list of users (usernames) that are members of this group.
#   - Only supplementary groups are listed in /etc/group, the primary group is listed in /etc/passwd.

# Define function sudoIf, which runs run a passed in function  as sudo if the userId is NOT 0. or as is without the sudo prefix if the userId is 0.
# Thus, run passed in command as sudo if current user is not "root" (i.e. userId is not 0), otherwise run command as is.
sudoIf() { if [ "$(id -u)" -ne 0 ]; then sudo "$@"; else "$@"; fi; }

# Set environment variable SOCKET_GID to the output of stat, which is a command that outputs
# information about a file, using the format specified with the -c option.
# Format option %g makes stat output the group ID of the file owner.
# In other words, we set the group ID of the owner of docker.sock, to the SOCKET_GID environment variable.
# In normal docker situations, SOCKET_GID will be 1001, because docker.sock file is created by default user in image, which is "ubuntu", whose GID is 1001.
SOCKET_GID=$(stat -c '%g' /var/run/docker.sock)

# Check if SOCKET_GID is not 0 (root)
if [ "${SOCKET_GID}" != '0' ]; then
  # If the group with GID SOCKET_GID, i.e. 1001, does not exist in /etc/group, create it with group name "docker-host".
  # In our standard docker image, SOCKET_GID is 1001, which does exist in /etc/group with group name "ubuntu" and one member with username "nfu".
  if [ "$(grep ":${SOCKET_GID}:" /etc/group)" = '' ]; then sudoIf groupadd --gid "${SOCKET_GID}" docker-host; fi
  # If user nfu's group ID does NOT match SOCKET_ID, which it does not because GID of nfu is 1000 and not 1001,
  # then ADD user nfu to group with GID SOCKET_GID, i.e. 1001, which is the group "ubuntu".
  # Result: Group ubuntu has two members, its primary member "ubuntu" and a supplementary member "nfu".
  if [ "$(id nfu | grep -E "groups=.*(=|,)${SOCKET_GID}\\(")" = '' ]; then sudoIf usermod -aG "${SOCKET_GID}" nfu; fi
fi

# - Finally, we execute the command passed in as argument to this script, which for docker is: sleep infinity.
# - Since this command is run by a bash shell inside the container (the default shell is set in the Dockerfile),
#   sleep will block that shell from exiting, thus keep the container running until it is stopped.
# - To see the processes running in the container: ps aux
#   - a: Show processes from all users.
#   - u: Show user/owner of process.
#   - x: Include processes not associated with a terminal, like system services.
# - Docker will create a new process with PID 1, which calls /sbin/docker-init -- ENTRYPOINT command/script,
#   where -- is present to signal end of command options, aka. flags, so ENTRYPOINT command is not interpreted as flags to docker-init.
# - The ENTRYPOINT script will be executed in a NEW sub-shell, e.g. with PID 7, as is always the case when one script calls another script.
# - The ENTRYPOINT script will use CMD command(s) as arguments, which in this case is: sleep infinity.
# - When the ENTRYPOINT script runs, it will execute its passed in arguments as shell commands, with: exec $@.
# - If exec had not been present, the shell running the ENTRYPOINT script, i.e. PID 7, would have spawned yet another sub-shell to run CMD command(s): sleep infinity.
# - Instead, with exec, the current shell running the ENTRYPOINT script, i.e. PID 7, will be replaced by the shell executing the sleep command.
# - The sleep infinity command will keep that shell, i.e. PID 7, running forever, until the container is shut down.
# - IMPORTANT: These shell processes are not associated with a terminal, instead they are so called daemon processes, which run in the background.
# - If sleep infinity proccess was assiciated with a terminal, that terminal would have been blocked, i.e. frozen,
#   because the sleep command makes the shell wait for the given period.
# - So, now we have a container running a shell indefinitely in the background, which keeps the container alive.
# - Remember: Containers are only alive as long as the commands they are made to execute, with ENTRYPOINT and CMD, are running.
# - As a next step, we may attach VS Code to the container, or execute another command within the container from the outside,
#   e.g. docker exec -it <containerId> bash, which will open a bash shell within the container.
# - When VS Code is attached to the container, it will run various files with node, from /tmp/ folder,
#   presumably to run all the extensions and similar.
# - Preferrably, execute the command: docker exec -it <containerId> zsh, to open a ZSH shell with a terminal inside the container,
#   then cd to the project folder, then run nvim from there.
# - Type "exit" to get out of the container.

# Start SSH daemon
sudoIf /usr/sbin/sshd -D &

exec "$@"
