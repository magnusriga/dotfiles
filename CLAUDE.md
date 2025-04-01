# Claude Guidelines for dotfiles repository

## Commands

- **Update Repository**: `git pull origin main`
- **Run Setup Script**: `. ~/dotfiles/scripts/bootstrap.sh`

## Style Guidelines

- **Shebang**: Use `#!/usr/bin/env bash` for shell scripts
- **Indentation**: 2 spaces
- **Comments**: Use `#` for comments, block comments with `# ==========` headers
- **Path Handling**: Use `SCRIPTPATH="$( cd -- "$(dirname "$BASH_SOURCE")" >/dev/null 2>&1 ; pwd -P )/"` for script paths
- **Conditionals**: Use `if [ -f "./file.sh" ]; then` style with spaces
- **Functions**: Define with `function name() { ... }` and `unset` after use
- **Error Handling**: Check commands exist before running, use conditionals for failures
- **Variables**: Use uppercase for constants, lowercase for local variables
- **Quoting**: Always quote variable references to prevent word splitting
- **Sourcing**: Use `. ./script.sh` for sourcing scripts to maintain environment

## Development Flow

- Setup environment first with bootstrap.sh
- Implement changes to configuration files in stow directory
- Apply changes with stow commands
- Check changes with relevant commands
- Commit with descriptive messages
