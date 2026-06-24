# System Admin Helper

System Admin Helper is a Bash/whiptail menu application for common Linux user and group administration tasks.

## Features

- Add, modify, delete, list, enable, and disable users.
- Add, modify, delete, and list groups.
- Change user passwords.
- Root/dependency checks before privileged actions run.
- Portable launcher that works from the repository root or from the `scripts/` directory.
- Logs command output to `scripts/logs` during local runs.

## Requirements

Run on a Linux system with root privileges and the standard shadow user-management tools.

Fedora/RHEL:

```bash
sudo dnf install newt xterm-resize shadow-utils
```

Debian/Ubuntu:

```bash
sudo apt-get install whiptail xterm passwd login
```

openSUSE:

```bash
sudo zypper install newt xterm shadow
```

`resize` is optional. If it is unavailable, the app falls back to the terminal dimensions reported by `tput`.

## Usage

From the repository root:

```bash
sudo ./scripts/main.sh
```

Or from the scripts directory:

```bash
cd scripts
sudo ./main.sh
```

The launcher validates privileges and dependencies before opening the main menu. It no longer installs packages automatically.

## Development Checks

Run Bash syntax checks:

```bash
for file in scripts/*.sh; do bash -n "$file" || exit 1; done
```

Run a non-root smoke test:

```bash
bash scripts/main.sh
```

Expected result:

```text
Privileges Error!: Error! Please run as root user.
```
