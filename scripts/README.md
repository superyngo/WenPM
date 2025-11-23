# Wenget Shell Script

A lightweight shell script alternative to the Rust version of Wenget. Perfect for platforms where compilation is difficult or when you need a quick, dependency-free solution.

## Quick Start

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/superyngo/Wenget/main/scripts/wenget.sh | bash -s init
```

After installation, restart your terminal or run:
```bash
source ~/.bashrc  # or ~/.zshrc, ~/.profile
```

## Features

- ✅ **Zero compilation** - Pure bash script
- ✅ **Minimal dependencies** - Only requires bash, curl, tar, gzip
- ✅ **Platform detection** - Auto-detects OS and architecture
- ✅ **musl priority** - Prefers musl binaries on Linux
- ✅ **GitHub integration** - Install directly from any GitHub repo

## Commands

### Install a package from bucket

```bash
wenget install <package>
# or
wenget add <package>
```

Example:
```bash
wenget install ripgrep
wenget install fd
```

### List available packages

```bash
wenget listsources
# or
wenget search
```

### List installed packages

```bash
wenget list
# or
wenget ls
```

### Remove a package

```bash
wenget remove <package>
# or
wenget del <package>
# or
wenget rm <package>
```

### Install from GitHub repository

Install any binary package directly from a GitHub repository:

```bash
wenget installrepo <github-url>
```

Examples:
```bash
wenget installrepo https://github.com/BurntSushi/ripgrep
wenget installrepo https://github.com/sharkdp/fd
wenget installrepo https://github.com/charmbracelet/glow
```

The script will:
1. Fetch the latest release
2. Auto-detect your platform (OS + architecture)
3. Find the matching binary asset
4. Download and install it

**Note:** Packages installed via `installrepo` are NOT tracked in the bucket system and won't receive updates through the normal update mechanism.

## Requirements

### Required Tools

- `bash` (4.0+)
- `curl`
- `tar`
- `gzip`

### Optional Tools

- `jq` - For better JSON parsing (highly recommended)
- `unzip` - For .zip archives
- `xz` - For .tar.xz archives

Install jq on various systems:
```bash
# Debian/Ubuntu
sudo apt-get install jq

# macOS
brew install jq

# Alpine
sudo apk add jq

# Fedora/RHEL
sudo dnf install jq
```

## Platform Support

The script auto-detects your platform and prefers musl builds on Linux:

- **Linux**: x86_64, aarch64, armv7, i686 (musl/gnu)
- **macOS**: x86_64, aarch64 (Apple Silicon)

Priority order for Linux:
1. `linux-{arch}-musl`
2. `linux-{arch}-gnu`
3. `linux-{arch}`

## Directory Structure

```
~/.wenget/
├── apps/           # Installed applications
│   ├── wenget/    # The script itself
│   ├── ripgrep/
│   └── fd/
├── bin/            # Symlinks (add to PATH)
│   ├── wenget -> ../apps/wenget/wenget.sh
│   ├── rg -> ../apps/ripgrep/rg
│   └── fd -> ../apps/fd/fd
└── cache/          # Temporary download cache
```

## Comparison: Script vs Rust

| Feature | wenget.sh | wenget (Rust) |
|---------|-----------|---------------|
| Installation | Instant | Requires compilation |
| Dependencies | bash, curl, tar | None (static binary) |
| Platform Support | Most Unix-like | All major platforms |
| Package Management | Basic | Full-featured |
| Update Mechanism | Manual | Automatic |
| Bucket Management | Read-only | Full CRUD |
| Performance | Moderate | Fast |
| File Size | ~20KB | ~5MB |

## Use Cases

**Use wenget.sh when:**
- ✅ Compilation fails on your platform
- ✅ You need a quick tool installer
- ✅ Running in CI/CD environments
- ✅ Limited disk space
- ✅ Just need to install a few tools

**Use wenget (Rust) when:**
- ✅ You need full package management
- ✅ You want automatic updates
- ✅ You manage multiple package sources
- ✅ You need better performance

## Troubleshooting

### Script not found after installation

Make sure `~/.wenget/bin` is in your PATH:

```bash
echo 'export PATH="$HOME/.wenget/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### jq not found warning

The script works without `jq` but with limited functionality. Install jq for the best experience:

```bash
sudo apt-get install jq  # Debian/Ubuntu
brew install jq          # macOS
```

### Permission denied

Make sure the script is executable:

```bash
chmod +x ~/.wenget/apps/wenget/wenget.sh
```

### Package not found for platform

The package might not have a binary for your platform. Try:

```bash
wenget listsources  # Check if your platform is supported
```

Or use `installrepo` to install directly from GitHub:

```bash
wenget installrepo https://github.com/user/repo
```

## Examples

### Basic Workflow

```bash
# Install the script
curl -fsSL https://raw.githubusercontent.com/superyngo/Wenget/main/scripts/wenget.sh | bash -s init

# Reload shell
source ~/.bashrc

# See what's available
wenget listsources

# Install some tools
wenget install ripgrep
wenget install fd
wenget install bat

# List installed
wenget list

# Remove a tool
wenget remove bat
```

### Install from GitHub

```bash
# Install a tool not in the bucket
wenget installrepo https://github.com/junegunn/fzf

# Install a specific tool
wenget installrepo https://github.com/jesseduffield/lazygit
```

## Contributing

The script is designed to be simple and maintainable. Contributions welcome!

## License

MIT License - Same as Wenget project
