# Thom's dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

Installation suggestion:

- Install: `snap install chezmoi --classic`
- Ensure git is installed: `sudo apt install git`
- Pull the repo: `chezmoi init https://github.com/ThomWright/dotfiles.git`
- Edit `~/.config/chezmoi/chezmoi.{json|toml|yaml}` to override any variables in `.chezmoidata.toml`
- Check `chezmoi diff`
- Run using: `chezmoi apply`
