# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Setup on a new machine

### macOS (Apple Silicon)

One command installs Homebrew (if missing), installs chezmoi, and applies the
dotfiles:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rlandgrebe/dotfiles/main/bootstrap.sh)"
```

See [`bootstrap.sh`](bootstrap.sh) for what it does.

### Other platforms

A bootstrap script for Linux (and other package managers) is planned. For now,
install [chezmoi](https://www.chezmoi.io/install/) yourself and run:

```sh
chezmoi init --apply rlandgrebe/dotfiles
```

## License

[MIT](LICENSE)
