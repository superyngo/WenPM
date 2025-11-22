# Wenget Package Sources

This directory contains curated lists of popular CLI tools from GitHub that can be installed via Wenget.

## Available Source Lists

### 📦 `sources-essential.txt`
Essential CLI tools that every developer should have. Includes:
- **Search & Find**: ripgrep, fd
- **File Viewing**: bat
- **Navigation**: zoxide, eza
- **Monitoring**: bottom, dust
- **Development**: tokei, hyperfine, delta
- **Git**: gitui
- **Shell**: starship
- **Wenget Official**: Wenget, cate, wedi

### 📚 `wenget-sources.txt`
Comprehensive list of popular CLI tools including:
- All tools from essential list
- Additional utilities: nushell, xh, ouch, hexyl
- More git tools: lazygit
- Text processing: sd, xsv, jq
- And more...

## Usage

### Import all sources at once:

Wenget supports two import formats:
- **txt format** - URL list (requires GitHub API calls)
- **json format** - Complete package info (no API calls, faster!)

```bash
# Import essential tools (recommended for beginners)
# txt format - will fetch package info from GitHub
wenget source import sources-essential.txt

# json format - instant import with complete package info
wenget source import sources-essential.json

# Import comprehensive list
wenget source import wenget-sources.txt

# Import from URL (if hosted on GitHub)
wenget source import https://raw.githubusercontent.com/superyngo/Wenget/main/sources-essential.json
```

**💡 Pro Tip:** Use JSON format to avoid GitHub API rate limits! JSON files contain complete package information and import instantly without fetching from GitHub.

### Export your sources:

```bash
# Export as txt (URLs only)
wenget source export -o my-sources.txt

# Export as JSON (complete package info - recommended for sharing!)
wenget source export -o my-sources.json -f json

# Export to stdout
wenget source export
```

### Using Buckets (Remote Manifest Sources):

**Buckets** are remote manifest sources that provide pre-built package information, eliminating the need for GitHub API calls and greatly improving performance.

#### Why use buckets?
- ✨ **Zero API calls** - No GitHub API rate limits
- ⚡ **Instant access** - Package info is pre-fetched
- 🌐 **Offline-capable** - Cache lasts 24 hours
- 📦 **Curated collections** - Maintained package lists

#### Bucket commands:

```bash
# Add a bucket (official or community)
wenget bucket add official https://raw.githubusercontent.com/user/wenget-bucket/main/manifest.json

# List all buckets
wenget bucket list

# Remove a bucket
wenget bucket del official

# Refresh cache from all buckets
wenget bucket refresh
```

#### How buckets work:

1. **Bucket sources** use the same `manifest.json` format as local sources
2. When you add a bucket, Wenget fetches its manifest and caches it locally
3. All package operations (search, list, install) use the **cached manifest** (includes local + bucket packages)
4. **Local sources** always take priority over bucket sources
5. Cache automatically refreshes after 24 hours or when you run `bucket refresh`

#### Creating your own bucket:

1. Export your sources as JSON:
   ```bash
   wenget source export -o manifest.json -f json
   ```

2. Host the `manifest.json` file on GitHub or any public URL

3. Users can add your bucket:
   ```bash
   wenget bucket add your-bucket https://your-url/manifest.json
   ```

**💡 Pro Tip:** Buckets are perfect for teams or organizations to share curated package collections without requiring users to import individual packages!

### After importing, install packages:

```bash
# List available packages
wenget source list

# Get package information
wenget source info ripgrep

# Install packages
wenget add ripgrep fd bat
```

## Tool Descriptions

### 🔍 Search & Find
- **ripgrep** (`rg`) - Extremely fast grep alternative, recursively searches directories
- **fd** - Simple, fast alternative to `find` with intuitive syntax

### 📄 File Viewers
- **bat** - `cat` clone with syntax highlighting and Git integration
- **cate** - Lightweight file viewer with encoding support

### 📁 Navigation
- **zoxide** - Smarter `cd` command that learns your habits
- **eza** - Modern replacement for `ls` with colors and icons

### 📊 System Monitoring
- **bottom** (`btm`) - Cross-platform graphical process/system monitor
- **dust** - More intuitive version of `du` (disk usage)
- **procs** - Modern replacement for `ps` (process viewer)

### 💻 Development Tools
- **tokei** - Count lines of code, quickly
- **hyperfine** - Command-line benchmarking tool
- **delta** - Syntax-highlighting pager for git and diff output

### 🔧 Git Tools
- **gitui** - Blazing fast terminal UI for git
- **lazygit** - Simple terminal UI for git commands
- **wedi** - Git worktree management tool

### 🎨 Shell Enhancement
- **starship** - Minimal, fast, and customizable prompt for any shell
- **nushell** - A new type of shell

### 📝 Text Processing
- **sd** - Intuitive find & replace CLI (`sed` alternative)
- **xsv** - Fast CSV command line toolkit
- **jq** - Lightweight and flexible command-line JSON processor

### 🌐 Network Tools
- **xh** - Friendly and fast tool for sending HTTP requests

### 📦 Compression
- **ouch** - Painless compression and decompression

### 🔢 Other Utilities
- **hexyl** - Command-line hex viewer
- **grex** - Generate regular expressions from test cases
- **watchexec** - Execute commands in response to file modifications

## Contributing

To add a new tool to the sources list:

1. Ensure the tool:
   - Has binary releases on GitHub
   - Provides pre-built binaries for major platforms (Windows, Linux, macOS)
   - Is actively maintained
   - Is a useful CLI tool

2. Add the GitHub repository URL to the appropriate source list

3. Update this README with a brief description

## Notes

- All tools listed here are open source and hosted on GitHub
- Binary availability may vary by platform
- Use `wenget source info <package>` to check supported platforms
- Some tools may require additional setup or configuration

## Package Manager Comparison

Wenget focuses on installing pre-built binaries from GitHub releases, making it:
- ✅ Fast (no compilation required)
- ✅ Cross-platform (Windows, Linux, macOS)
- ✅ Simple (just download and use)
- ✅ No dependencies on other package managers

## Support

For issues or questions:
- Wenget: https://github.com/superyngo/Wenget/issues
- Each tool has its own repository with documentation and issue tracker
