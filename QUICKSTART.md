# Wenget Quick Start Guide

Get started with Wenget in just a few minutes!

## 🚀 Installation

### Option 1: From Release (Recommended)
```bash
# Download the latest release from GitHub
# Extract and run wenget init
```

### Option 2: Build from Source
```bash
git clone https://github.com/superyngo/Wenget.git
cd Wenget
cargo build --release
./target/release/wenget init
```

## 📦 First Steps

### 1. Initialize Wenget
This creates the necessary directories and sets up PATH:
```bash
wenget init
```

After initialization, **restart your terminal** for PATH changes to take effect.

### 2. Import Package Sources
Import our curated list of essential CLI tools:
```bash
# Recommended: JSON format (faster, no API calls)
wenget source import sources-essential.json

# Alternative: txt format (will fetch from GitHub API)
wenget source import sources-essential.txt
```

**💡 Tip:** JSON format is recommended as it contains complete package info and doesn't require GitHub API calls!

### 3. View Available Packages
See what packages are available for your platform:
```bash
wenget source list
```

### 4. Install Your First Package
Let's install `ripgrep`, a blazing fast search tool:
```bash
wenget add ripgrep
```

### 5. Use Your Installed Tool
```bash
rg "search text" .
```

## 🔥 Recommended Starter Pack

Install these essential tools to supercharge your command line:

```bash
# Search tools
wenget add ripgrep fd

# File viewer
wenget add bat

# Navigation
wenget add zoxide eza

# System monitoring
wenget add bottom

# Development
wenget add hyperfine starship
```

## 📖 Common Commands

### Source Management
```bash
# List available packages from sources
wenget source list

# Show package information
wenget source info ripgrep

# Refresh package metadata
wenget source refresh

# Add a specific package source
wenget source add https://github.com/user/repo

# Export your sources list
wenget source export -o my-sources.txt        # txt format (URLs)
wenget source export -o my-sources.json -f json  # JSON format (full info)
```

### Bucket Management (Remote Sources)
```bash
# Add a bucket (curated package collections)
wenget bucket add official https://url/to/manifest.json

# List all buckets
wenget bucket list

# Remove a bucket
wenget bucket del official

# Refresh cache from buckets
wenget bucket refresh
```

### Package Management
```bash
# Install packages
wenget add ripgrep fd bat

# List installed packages
wenget list

# Search for packages (in sources)
wenget search grep

# Update installed packages
wenget update ripgrep
wenget update all

# Remove packages
wenget del ripgrep
```

## 💡 Pro Tips

### 1. Use Wildcards
```bash
# Install multiple packages matching a pattern
wenget add *grep

# Update all packages from a specific author
wenget update sharkdp/*
```

### 2. Auto-confirm Installations
Skip confirmation prompts with `-y`:
```bash
wenget add ripgrep fd bat -y
```

### 3. Check Before Installing
Always check package info before installing:
```bash
wenget source info ripgrep
```

### 4. Keep Sources Updated
Regularly update your package sources to get the latest versions:
```bash
wenget source update
```

## 🌟 Tool Showcase

### ripgrep (rg)
**Ultra-fast text search**
```bash
# Search for "TODO" in all files
rg TODO

# Search in specific file types
rg "error" --type rust

# Case-insensitive search
rg -i "hello"
```

### fd
**Modern find alternative**
```bash
# Find files by name
fd config

# Find by extension
fd -e rs

# Execute commands on results
fd -e jpg -x convert {} {.}.png
```

### bat
**Cat with syntax highlighting**
```bash
# View a file with syntax highlighting
bat README.md

# Show line numbers
bat -n file.rs

# View with paging
bat --paging=always large-file.log
```

### zoxide
**Smarter cd command**
```bash
# After using cd a few times, jump directly
z documents
z proj
z down
```

### eza
**Modern ls replacement**
```bash
# List files with details
eza -la

# Tree view
eza --tree

# Git status integration
eza --git
```

### bottom (btm)
**System monitor**
```bash
# Launch the TUI
btm

# Basic mode
btm --basic
```

### starship
**Cross-shell prompt**
```bash
# Already configured after installation!
# Your prompt will show git status, language versions, etc.
```

## 🔧 Troubleshooting

### PATH not updated?
1. Make sure you ran `wenget init`
2. Restart your terminal
3. Check PATH manually:
   - Windows: `echo %PATH%`
   - Linux/macOS: `echo $PATH`

### Command not found after installation?
1. Verify installation: `wenget list`
2. Check if binary exists:
   - Windows: `dir %USERPROFILE%\.wenget\bin`
   - Linux/macOS: `ls ~/.wenget/bin`
3. Restart terminal

### Package fails to install?
1. Check platform support: `wenget source info <package>`
2. Update sources: `wenget source update`
3. Check GitHub releases manually

## 📚 Learn More

- [Full Command Reference](SOURCES.md)
- [Package Sources](SOURCES.md)
- [Report Issues](https://github.com/superyngo/Wenget/issues)

## 🎉 What's Next?

1. Explore more packages: `wenget source list`
2. Install tools that match your workflow
3. Share your sources list: `wenget source export`
4. Contribute packages to the community!

---

**Happy package managing! 🚀**
