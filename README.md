# README

## Setup Linux | Development Container

### Host Pre-Requisites

1. Install terminal.
2. Install JetBrains Mono Nerd Font.
3. Create SSH key: `ssh-keygen -t ed25519 -f "$HOME"/.ssh/magnusriga_ed25519`.
4. Add SSH key to `magnusriga` GitHub.
5. Add SSH key to agent: `ssh-add "$HOME"/.ssh/magnusriga_ed25519`.
6. Install `git`:
   a. Arch: `sudo pacman -Syu git`
   b. Ubuntu: `sudo apt update && sudo apt upgrade -y && sudo apt install -y git`.
7. Clone dotfiles: `git clone git@github.com:magnusriga/dotfiles.git "$HOME"/dotfiles`.
8. Clone nfront: `git clone git@github.com:magnusriga/nfront.git`.
9. Symlink SSH config: `ln -s "$HOME"/dotfiles/host/.ssh/config "$HOME"/.ssh/config`.

### Normal (non-docker)

Pre-Requisites: [Host Pre-Requisites](#host-pre-requisites)

1. Create user: `. ~/dotfiles/scripts/bootstrap.sh`.
2. Switch to new user: `nfu`.
3. Clone dotfiles: `git clone git@github.com:magnusriga/dotfiles.git "$HOME"/dotfiles`.
4. Re-run script to prepare machine: `. ~/dotfiles/scripts/bootstrap.sh`.

### Docker

Pre-Requisites: [Host Pre-Requisites](#host-pre-requisites)

1. Build and access: `. ~/dotfiles/host/docker/manage-container.sh -b [-t ubuntu]`.
2. Re-access: `ssh nfu-docker`.
3. Everything else is automatic.

### OrbStack Linux Machine

Pre-Requisites: [Host Pre-Requisites](#host-pre-requisites)

1. Enter machine with default user: `orb -m <machine>`.
2. Install `git`:
   a. Arch: `sudo pacman -Syu git`
   b. Ubuntu: `sudo apt -y modernize-sources && sudo apt update && sudo apt upgrade -y && sudo apt install -y git`.
3. Clone dotfiles: `git clone git@github.com:magnusriga/dotfiles.git "$HOME"/dotfiles`.
4. Create user: `. ~/dotfiles/scripts/bootstrap.sh`.
5. Set socket permissions:
   a. `sudo chmod 766 /opt/orbstack-guest/run/*`
   b. `sudo chmod 766 /opt/containerd`
   c. Must be re-run every time OrbStack restarts.
   d. Fixes ssh agent permission issues on new user.
6. Switch to new user: `orb -m <machine> -u nfu`.
7. Clone dotfiles: `git clone git@github.com:magnusriga/dotfiles.git "$HOME"/dotfiles`.
8. Re-run script to prepare machine: `. ~/dotfiles/scripts/bootstrap.sh`.
9. **HOST**:
   a. Create SSH keys: `ssh-keygen -t ed25519 -f ~/.ssh/<user>-<machine>_ed25519`
   b. Update SSH config:

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

c. Add SSH key to agent: `ssh-add ~/.ssh/<user>-<machine>_ed25519`.
d. Test SSH connection, with password: `ssh <user>-<machine>`.
e. Copy SSH key to container: `ssh-copy-id -i ~/.ssh/<user>-<machine>_ed25519.pub <user>-<machine>`, with password `nfu`.
f. Test SSH connection, with SSH agent: `ssh <user>-<machine>`.
g. Copy terminfo to container: `infocmp -x | ssh <user>-<machine> -- tic -x -`.

- General notes:
  - Sometimes step (6) hangs first time, just try step (6) again.
- OrbStack Linux machine notes:
  - SSH agent is forwarded automatically to Linux machine.
  - Thus: Skip above steps 1-5 inside Linux machine.
  - But: Still need above pre-requisites on host machine.
  - Alternative: Use Docker container for easy setup, see below.
- If `ssh` fails:
  - Log in to server with `orb`.
  - Check permissions: `~/.ssh` has 700.
  - Check permissions: `~/.ssh/authorization_keys` has 600, created with `ssh-copy-id`.
  - Ensure SSH agent does not contain more keys than `MaxAuthTries` in `/etc/ssh/sshd_config`,
    because SSH will never get to password prompt then.

## Attach to Development Container

1. Start containers: `. ~/dotfiles/host/docker/manage-container.sh -u`.
1. Enter development container, either:
   a. `ssh nfu-docker`.
   b. `. ~/dotfiles/host/docker/manage-container.sh -s`.

## Do NOT Use Docker Swarm Mode for Development Containers

- Docker swarm mode should not be used for development containers.
- Containers are recreated when host restarts.
- Therefore, do not use:
  - `./.devcontainer/stack-build.sh -e dev`.
  - `./.devcontainer/stack-deploy.sh -e dev`.
- Instead, use `docker compose build` and `docker compose up`.

## Post Setup Configuration

- Transition `claude` to local install: `yes | pnpm claude migrate-installer`.
- Login to `claude`: `claude`, then follow steps.
- Login to `gh`: `gh auth login`, then follow steps.
- Login to `Copilot` in Neovim, for shadow-text, i.e. smart auto-complete:
  - `nvim`
  - `:Copilot auth`
  - Follow steps

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
