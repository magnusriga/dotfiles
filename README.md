# README

## Setup Linux | Development Container

### Host Pre-Requisites

1. Install terminal.
2. Install JetBrains Mono Nerd Font.
3. Create SSH key: `ssh-keygen -t ed25519 -f "$HOME"/.ssh/magnusriga_ed25519`.
4. Add SSH key to `magnusriga` GitHub.
5. Add SSH key to agent: `ssh-add "$HOME"/.ssh/magnusriga_ed25519`.
6. Install `git`:
   a. Arch: `sudo pacman -Syu <pkg>`
   b. Ubuntu: `sudo apt update && sudo apt upgrade -y && sudo apt install -y <pkg>`.
7. Clone dotfiles: `git clone git@github.com:magnusriga/dotfiles.git`.
8. Clone nfront: `git clone git@github.com:magnusriga/nfront.git`.

### Normal (non-docker)

Pre-Requisites: [Host Pre-Requisites](#host-pre-requisites)

1. Create user: `. ~/dotfiles/scripts/bootstrap.sh`.
2. Switch to new user: `nfu`.
3. Re-run script to prepare machine: `~/dotfiles/scripts/bootstrap.sh`.

### Docker

Pre-Requisites: [Host Pre-Requisites](#host-pre-requisites)

1. `. ~/dotfiles/host/docker/manage-container.sh -b`.
2. Everything else is automatic.

## Attach to Development Container

1. Start containers: `. ~/dotfiles/host/docker/manage-container.sh -u`.
1. Enter development container, either:
   a. `ssh nfu-docker`.
   b. `. ~/dotfiles/host/docker/manage-container.sh -s`.

## Notes: Key Steps - Incomplete, Only for Information Purposes

**Host**:

- Install Linux | OrbStack container or machine.
- Open new machine | container: `orb -u root -m <new_machine_name>`.
- Set password to `magnus`: `passwd magnus`.
- Setup package manager.
  - `sudo pacman-key init && sudo pacman-key --populate && sudo pacman -Syu --noconfirm archlinux-keyring`.
- Install initial packages: `sudo pacman -Syu --noconfirm which openssh vim git`.

**Docker | VM**:

- Open container | machine.
  - `orb -m <machine-name>`.
- Symlink `/etc/ssh/sshd_config` to `~/dotfiles/etc/ssh/sshd_config`.
  - Result: Listen to port `2222`.
- Start `sshd`.
  - `sudo systemctl start sshd && sudo systemctl enable sshd && sudo systemctl reload sshd`.
  - Every time `/etc/ssh/sshd_config` changes: `sudo systemctl reload sshd`.

**Host**:

- Create SSH keys.
  - `ssh-keygen -t ed25519 -f ~/.ssh/<user>-<machine>_ed25519`
- Update `~/.ssh/config`.

  ```bash
  Host <user>-<machine>
    HostName 198.19.249.136 # From OrbStack
    Port 2222
    User nfu
    IdentityFile ~/.ssh/<user>-<machine>_ed25519
    ForwardAgent yes
    SendEnv TERM_PROGRAM
    SendEnv DISPLAY
  ```

- Add SSH key to agent.
  - `ssh-add ~/.ssh/<user>-<machine>_ed25519`.
  - Avoids typing passphrase and forwards key to container.
- Test SSH connection, with password.
  - `ssh <user>-<machine>`.
- Copy SSH key to container.
  - `ssh-copy-id -i ~/.ssh/<user>-<machine>_ed25519.pub <host>`.
  - `<host>`: `<user>-<machine>` from `~/ssh/config`.
  - Type password to remote user, e.g. `nfu`.
- Test SSH connection, with SSH agent.
  - `ssh <user>-<machine>`.
- Copy terminfo to container.
  - `infocmp -x | ssh <user>-<machine> -- tic -x -`.
- If `ssh` fails:
  - Log in to server with `orb`.
  - Check permissions: `~/.ssh` has 700.
  - Check permissions: `~/.ssh/authorization_keys` has 600.

### Do NOT Use Docker Swarm Mode for Development Containers

- Docker swarm mode should not be used for development containers.
- Containers are recreated when host restarts.
- Therefore, do not use:
  - `./.devcontainer/stack-build.sh -e dev`.
  - `./.devcontainer/stack-deploy.sh -e dev`.
- Instead, use `docker compose build` and `docker compose up`.

## Install and Run Pre-Commit Hooks

- Not needed, automatic during `nfront` > `pnpm i`.
- Before:
  - Add hooks to `.git/hooks`, by running: `pre-commit install`
  - Run added hooks on all files: `pre-commit run --all-files`

## Running Production Containers

- Not setup yet.

### Preliminary Notes

1. Build image from Linux (once): `./scripts/compose-build.sh -e prod`
2. Deploy stack from Linux (every time we run container): `./scripts/stack-deploy.sh -e prod`
3. Check by visiting: [localhost](http://localhost:3000)

If `git clone` does not work:

1. Host: `ssh-add -L`, to check public key in ssh-agent.
2. Remote: `ssh-add -L`, to check it matches public key in ssh-agent in Host.

Other Notes

- Manually add name and email to `.gitconfig`: `. ~/dotfiles/_unused/setup_git_credentials.sh`.
- Prompt slightly delayed due to `git_status`, remove git status to avoid.
