# Wenget Documentation Index

Welcome to Wenget! This document helps you navigate all available documentation.

## 📚 Documentation Files

### For Users

#### 🚀 [QUICKSTART.md](QUICKSTART.md)
**Start here if you're new to Wenget!**
- Installation instructions
- First steps tutorial
- Common commands
- Tool showcase with examples
- Troubleshooting guide

#### 📦 [SOURCES.md](SOURCES.md)
**Complete package sources reference**
- Available source lists
- Detailed tool descriptions by category
- Usage instructions for importing sources
- Contributing guidelines

#### 📖 [README.md](README.md)
**Project overview and main documentation**
- What is Wenget
- Features
- Installation guide
- Basic usage

### Package Source Lists

#### 🔷 [sources-essential.txt](sources-essential.txt)
**Recommended for beginners**
- 12 essential CLI tools
- Verified to work with Wenget
- Includes Wenget official tools (cate, wedi)
- Core utilities: ripgrep, fd, bat, zoxide, eza, bottom, dust, hyperfine, gitui, starship

Import with:
```bash
wenget source import sources-essential.txt
```

#### 🔶 [wenget-sources.txt](wenget-sources.txt)
**Comprehensive collection**
- Extended list of popular CLI tools
- Additional utilities beyond essential list
- Includes text processing, network tools, compression utilities

Import with:
```bash
wenget source import wenget-sources.txt
```

### For Developers

#### 🏗️ [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)
**Project development roadmap**
- Architecture overview
- Implementation phases
- Technical decisions
- Future features

## 🎯 Quick Navigation

### I want to...

**Get started quickly**
→ Read [QUICKSTART.md](QUICKSTART.md)

**See all available tools**
→ Read [SOURCES.md](SOURCES.md)

**Import popular tools**
→ Use [sources-essential.txt](sources-essential.txt)

**Learn about Wenget features**
→ Read [README.md](README.md)

**Contribute to Wenget**
→ Read [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) and [SOURCES.md](SOURCES.md#contributing)

## 📝 Quick Reference

### Common Commands

```bash
# Initialize Wenget
wenget init

# Import sources
wenget source import sources-essential.txt

# List available packages
wenget source list

# Show package info
wenget source info ripgrep

# Install packages
wenget add ripgrep fd bat

# List installed packages
wenget list

# Update packages
wenget update all

# Remove packages
wenget del package-name
```

### Source File Management

```bash
# Import from file
wenget source import sources-essential.txt

# Import from URL
wenget source import https://raw.githubusercontent.com/.../sources.txt

# Export your sources
wenget source export -o my-sources.txt

# Update package metadata
wenget source update

# Add single package
wenget source add https://github.com/user/repo

# Remove package from sources
wenget source del package-name
```

## 🔍 Finding Information

| I want to know... | Check this file... |
|------------------|-------------------|
| How to install Wenget | QUICKSTART.md |
| What tools are available | SOURCES.md |
| How a specific tool works | SOURCES.md (Tool Descriptions) |
| How to use Wenget commands | QUICKSTART.md (Common Commands) |
| How to troubleshoot issues | QUICKSTART.md (Troubleshooting) |
| How Wenget is built | DEVELOPMENT_PLAN.md |
| How to contribute packages | SOURCES.md (Contributing) |

## 🌟 Recommended Reading Order

### For New Users:
1. **QUICKSTART.md** - Get Wenget running in 5 minutes
2. **sources-essential.txt** - Import your first packages
3. **SOURCES.md** - Explore more tools

### For Power Users:
1. **SOURCES.md** - Discover all available tools
2. **wenget-sources.txt** - Import comprehensive collection
3. Create your own sources list!

### For Contributors:
1. **README.md** - Understand the project
2. **DEVELOPMENT_PLAN.md** - Learn the architecture
3. **SOURCES.md** - Add new packages

## 💡 Tips

- **Source lists** are just text files with one GitHub URL per line
- Comments start with `#`
- You can create your own source lists and share them
- Source lists can be imported from URLs or local files
- Use `wenget source export` to backup your sources

## 🔗 External Resources

- **GitHub Repository**: https://github.com/superyngo/Wenget
- **Issue Tracker**: https://github.com/superyngo/Wenget/issues
- **Cate**: https://github.com/superyngo/cate
- **Wedi**: https://github.com/superyngo/wedi

## 📧 Support

- Found a bug? [Open an issue](https://github.com/superyngo/Wenget/issues)
- Have a question? Check [QUICKSTART.md](QUICKSTART.md#troubleshooting)
- Want to contribute? See [SOURCES.md](SOURCES.md#contributing)

---

**Happy reading! 📖**
