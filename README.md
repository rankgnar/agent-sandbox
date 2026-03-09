# agent-sandbox 🏗️

> Linux-native sandboxing for AI coding agents.  
> Run Codex, Claude Code, Gemini CLI, and other agents safely — isolated at the kernel level using **bubblewrap (bwrap)**.

---

## Why?

AI coding agents like Claude Code and Codex operate with broad file system access. One misunderstood instruction, a hallucinated path, or a supply-chain compromise can expose your SSH keys, AWS credentials, or entire home directory.

`sandbox` wraps any agent command in a **bubblewrap container** that:

- ✅ Gives the agent full access to the **current project** (git root auto-detected)
- ❌ Blocks `~/.ssh`, `~/.aws`, `~/.config`, `~/.gnupg` and all other home directories
- ❌ Isolates the network by default (no exfiltration)
- ✅ Passes through only the env vars you allow (API keys forwarded safely)
- ✅ Works with any command — not just specific agents

---

## Requirements

- Linux (kernel 3.8+ for user namespaces)
- [`bubblewrap`](https://github.com/containers/bubblewrap)

```bash
# Debian / Ubuntu
sudo apt install bubblewrap

# Fedora / RHEL / CentOS
sudo dnf install bubblewrap

# Arch Linux
sudo pacman -S bubblewrap

# Alpine
apk add bubblewrap
```

> **Note:** Some distros require `sysctl kernel.unprivileged_userns_clone=1` for unprivileged user namespaces. If `bwrap` fails, run:
> ```bash
> sudo sysctl kernel.unprivileged_userns_clone=1
> # To persist:
> echo 'kernel.unprivileged_userns_clone=1' | sudo tee /etc/sysctl.d/99-userns.conf
> ```

---

## Installation

```bash
git clone https://github.com/rankgnar/agent-sandbox
cd agent-sandbox
./install.sh
```

Or install manually:

```bash
sudo install -m 755 sandbox /usr/local/bin/sandbox
```

---

## Usage

```bash
sandbox <command> [args...]
```

### Examples

```bash
# Run Claude Code inside the sandbox
sandbox claude --dangerously-skip-permissions

# Run Codex in full-auto mode
sandbox codex --full-auto

# Run Gemini CLI
sandbox gemini

# Open a sandboxed bash shell (for testing/exploration)
sandbox bash

# Dry-run: print the bwrap command without executing
sandbox --dry-run claude --dangerously-skip-permissions
```

---

## Options

| Flag | Description |
|------|-------------|
| `--allow-read=<path>` | Mount additional path as read-only |
| `--allow-write=<path>` | Mount additional path as read+write |
| `--allow-network` | Enable outbound network access |
| `--workdir=<path>` | Override working directory (default: git root or cwd) |
| `--no-git-detect` | Disable automatic git root detection |
| `--dry-run` | Print the bwrap command without running |
| `--version` | Show version |
| `--help` | Show help |

---

## What's allowed by default

| Resource | Access |
|----------|--------|
| Git project root (or cwd) | ✅ Read + Write |
| `/usr`, `/bin`, `/lib`, `/sbin` | ✅ Read-only (binaries) |
| `/etc` | ✅ Read-only (system config) |
| `/proc`, `/dev` | ✅ Minimal virtual mounts |
| `/tmp`, `/run` | ✅ Empty tmpfs |
| `~/.ssh` | ❌ Blocked |
| `~/.aws` | ❌ Blocked |
| `~/.config` | ❌ Blocked |
| `~/.gnupg` | ❌ Blocked |
| Other home dirs | ❌ Blocked |
| Network | ❌ Blocked (unless `--allow-network`) |

---

## Environment variables forwarded

The following env vars are passed through automatically (if set):

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`
- `TERM`, `COLORTERM`, `LANG`, `LC_ALL`

Sensitive vars like `AWS_SECRET_ACCESS_KEY`, `GH_TOKEN`, etc. are **not** forwarded unless you pass `--setenv` explicitly (planned feature).

---

## How it works

`sandbox` builds a `bwrap` command that:

1. **Detects the git root** of the current directory and mounts it read+write
2. **Mounts system binaries** (`/usr`, `/bin`, etc.) read-only so the agent can run commands
3. **Creates tmpfs** over `/home`, `/root`, `/tmp` — blocking all real home directory contents
4. **Unshares** PID, UTS, IPC, and network namespaces
5. **Overrides `$HOME`** to the project directory so the agent can't accidentally navigate to real home

The result: the agent runs normally inside its project but cannot see or touch anything outside it.

---

## Inspiration

Inspired by [Agent Safehouse](https://github.com/Stealth-R-D-LLC/agent-safehouse) (macOS/sandbox-exec) — this project brings equivalent protection to Linux using bubblewrap.

---

## License

MIT — see [LICENSE](LICENSE)
