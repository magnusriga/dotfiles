==================================
Setup Host (once).
==================================
0. Install terminal.
1. Install JetBrains Mono Nerd Font
2. `ssh-keygen`, save as `~/.ssh/nfu_ed25519`, and add to `IdentityFile` in `~/.ssh/config`, alongside: `Host: 127.0.0.1 Port: 2222 User nfu ForwardAgent Yes` (see: `dotfiles/_unused/.ssh/config`).
3. Repeat for `~/.ssh/github_ed25519`, with:  `Host: github.com User git`.
4. Add keys to ssh agent, so they can be forwarded to server: `ssh-add ~/.ssh/github_ed25519`.
5. Add `~/.ssh/github_ed25519.pub` to github.

==================================
Setup Linux.
==================================
01. Create new arch amd machine, named `arch`, which will get default user `magnus`.
02. Host: `orb -u root`, `passwd magnus`, and set password to `magnus`.
03. `sudo pacman-key init && sudo pacman-key --populate && sudo pacman -Sy archlinux-keyring && pacman -Syu —noconfirm which openssh vim git`, then modify config, `sudo vim /etc/ssh/sshd_config`, to listen to port 2222 (see: `dotfiles/_unused/etc/ssh/sshd_config`).
04. `sudo systemctl start sshd && sudo systemctl enable sshd`, and `sudo systemctl reload sshd` every time `/etc/ssh/sshd_config` changes.
05. Host: `ssh-copy-id -i ~/.ssh/nfu_ed25519.pub magnus@nfu`, type password to remote user `magnus`, as set above.
06. `ssh magnus@nfu`. If it fails, log in to server with `orb`, and check that `~/.ssh` has permissions 700, and `~/.ssh/authorization_keys` has 600.
07. Host: Copy terminfo to default user: `infocmp -x | ssh magnus@nfu -- tic -x -`.
08. `cd ~ && git clone git@github.com:magnusriga/dotfiles.git`.
09. `. ~/dotfiles/scripts/setup_user`.
10. Host: `ssh-copy-id -i ~/.ssh/nfu_ed25519.pub nfu`, type password to remote user `nfu`, which is also `nfu`.
11. Host: Copy terminfo to new user: `infocmp -x | ssh nfu -- tic -x -`.
12. Logout of remote machine and in again with new user: `ssh nfu`, then delete orbstack `ssh_config`: `sudo rm -rf /etc/ssh/ssh_config.d/10-orbstack.conf`.
14.  `cd ~ & git clone git@github.com:magnusriga/dotfiles.git`.
14. `. ~/dotfiles/scripts/bootstrap.sh`.

==================================
If git clone does not work:
==================================
1. Host: `ssh-add -L`, to check public key in ssh-agent.
2. Remote: `ssh-add -L`, to check it matches public key in ssh-agent in Host.

==================================
Other Notes
==================================
- Manually add name and email to `.gitconfig`: `. ~/dotfiles/_unused/setup_git_credentials.sh`.
- Prompt slightly delayed due to `git_status`, remove git status to avoid.