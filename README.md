# README

## Setup Host (once).

0. Install terminal.
1. Install JetBrains Mono Nerd Font
2. `ssh-keygen`, save as `~/.ssh/nfu_ed25519`, and add to `IdentityFile` in `~/.ssh/config`, alongside: `Host: 127.0.0.1 Port: 2222 User nfu ForwardAgent Yes` (see: `dotfiles/_unused/.ssh/config`).
3. Repeat for `~/.ssh/github_ed25519`, with: `Host: github.com User git`.
4. Add keys to ssh agent, so they can be forwarded to server: `ssh-add ~/.ssh/github_ed25519`.
5. Add `~/.ssh/github_ed25519.pub` to GitHub.

## Setup Linux.

1.  Create new arch AMD machine, named `arch`, which will get default user `magnus`.
2.  Host: `orb -u root -m <new_machine_name>`, `passwd magnus`, and set password to `magnus`.
3.  `sudo pacman-key init && sudo pacman-key --populate && sudo pacman -Syu --noconfirm archlinux-keyring && sudo pacman -Syu --noconfirm which openssh vim git`,
    then modify `sshd` config, `sudo vim /etc/ssh/sshd_config`, to listen to port 2222 (see: `dotfiles/_unused/etc/ssh/sshd_config`). Note: File is replaced later, during install.
4.  `sudo systemctl start sshd && sudo systemctl enable sshd && sudo systemctl reload sshd`, and `sudo systemctl reload sshd` every time `/etc/ssh/sshd_config` changes.
5.  Host: `ssh-copy-id -i ~/.ssh/nfu_ed25519.pub magnus@nfu`, type password to remote user `magnus`, as set above.
6.  Host: Copy terminfo to default user: `infocmp -x | ssh magnus@nfu -- tic -x -`.
7.  `ssh magnus@nfu`. If it fails, log in to server with `orb`, and check that `~/.ssh` has permissions 700, and `~/.ssh/authorization_keys` has 600.
8.  `cd ~ && git clone git@github.com:magnusriga/dotfiles.git`.
9.  `. ~/dotfiles/scripts/setup_user`.
10. Host: `ssh-copy-id -i ~/.ssh/nfu_ed25519.pub nfu`, type password to remote user `nfu`, which is also `nfu`.
11. Host: Copy terminfo to new user: `infocmp -x | ssh nfu -- tic -x -`.
12. Login with new user, `ssh nfu`, then delete OrbStack `ssh_config`: `sudo rm -rf /etc/ssh/ssh_config.d/10-orbstack.conf`.
13. `cd ~ & git clone git@github.com:magnusriga/dotfiles.git`.
14. `. ~/dotfiles/scripts/bootstrap.sh`.

## Setup Development Container.

### Create and Attach to Development Container.

1. Build image from Linux (once): `~/dotfiles/host/docker/compose-build.sh -e dev`
2. Deploy stack from Linux (every time container runs): `./.devcontainer/compose-up.sh -e dev`
3. If `vscode`, attach to running `nfront` container.
4. Manually run `pnpm i` and `pnpm dev`, as needed.

### Install and Run Pre-Commit Hooks.

1. Add hooks to `.git/hooks`, by running: `pre-commit install`
2. Run the added hooks on all files: `pre-commit run --all-files`

### Other Required Setup.

1. Install dotfiles (e.g. magnusriga/dotfiles) to get the necessary environment
   variables (pnpm, node, etc.), and for a better terminal experience.
2. Install Hack Nerd Font for the terminal to display icons correctly.

### Do NOT Use Docker Swarm Mode for Development Containers.

- Docker swarm mode should not be used for development containers, because the containers are recreated when the host restarts.
- Therefore, do not use: `./.devcontainer/stack-build.sh -e dev` and `./.devcontainer/stack-deploy.sh -e dev`
- Instead, use docker compose build and docker compose up.

## Running Production Containers.

1. Build image from Linux (once): `./scripts/compose-build.sh -e prod`
2. Deploy stack from Linux (every time we run container): `./scripts/stack-deploy.sh -e prod`
3. Check by visiting: [localhost](http://localhost:3000)

If git clone does not work:

1. Host: `ssh-add -L`, to check public key in ssh-agent.
2. Remote: `ssh-add -L`, to check it matches public key in ssh-agent in Host.

Other Notes

- Manually add name and email to `.gitconfig`: `. ~/dotfiles/_unused/setup_git_credentials.sh`.
- Prompt slightly delayed due to `git_status`, remove git status to avoid.
