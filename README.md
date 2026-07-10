# nclean

A fast, simple curses TUI for browsing and cleaning up NixOS system generations, built on top of `nh os info`.

![status](https://img.shields.io/badge/status-stable-brightgreen)

> **Note:** This project was built with AI assistance (vibecoded). I'm not a professional developer — I reviewed and tested it, but if you spot bugs, bad practices, or security issues, please open an issue or PR. Use at your own risk, especially anything touching `sudo`.

## Features

- Lists system generations with build date, NixOS version, kernel, and closure size.
- Mark individual generations, or everything below the cursor at once.
- Delete marked generations via `sudo nix-env --delete-generations`.
- Optional automatic `nix-collect-garbage` after deletion.
- Background refresh (separate thread) — the TUI never freezes while `nh` runs.
- Auto-refresh every 30s, plus manual refresh with `r`.

## Requirements

- Python 3.10+ (uses `list[...]`, `dataclass(slots=True)`)
- [`nh`](https://github.com/nix-community/nh) available on `PATH`
- `sudo` with permission to run `nix-env` / `nix-collect-garbage`
- A terminal with curses (ncurses) support

## Installation

### Run once, without installing

This downloads (and builds, if needed), then runs it immediately — nothing is left on your `PATH` afterwards:

```bash
nix run github:p0nczek/nclean
```

### Install permanently

This adds `nclean` to your Nix profile, so afterwards you can just type `nclean` in any terminal:

```bash
nix profile add github:p0nczek/nclean
nclean
```

### Manual (without Nix)

```bash
chmod +x nclean.py
./nclean.py
```

### NixOS / home-manager

Add it as a flake input to your own configuration and expose the package via `environment.systemPackages` or `home.packages`.

## Controls

| Key         | Action                                      |
|-------------|----------------------------------------------|
| ↑ / ↓       | Navigate the list                             |
| Space       | Mark / unmark a generation                    |
| `a`         | Mark cursor + everything below it             |
| `u`         | Unmark everything                             |
| `d`         | Delete marked generations (with `y/N` confirm)|
| `g`         | Toggle automatic GC after deletion            |
| `r`         | Force refresh the list                        |
| `q` / `Esc` | Quit                                           |

The current (active) generation can never be marked or deleted.

https://github.com/user-attachments/assets/c6031356-296d-46bf-940e-22dc7a027f3b





## How it works

`nclean.py` parses `nh os info` output with a regex and keeps the generation list in a thread-safe `Store`. Refreshing (`nh os info`) runs on a background daemon thread, so the UI draw loop (`main`) is never blocked for the duration of that call. Deleting generations (`sudo nix-env --delete-generations`) temporarily exits curses mode (`curses.endwin()`) so `sudo` can prompt for a password normally in the terminal, then returns to the TUI.

## License

MIT — do whatever you want with it.
