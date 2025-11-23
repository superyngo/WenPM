#!/usr/bin/env bash
#
# Wenget - Lightweight package manager for GitHub binaries
# A shell script alternative to the Rust version
#
# Usage:
#   Install: curl -fsSL https://raw.githubusercontent.com/superyngo/Wenget/main/scripts/wenget.sh | bash -s init
#   Commands: wenget [init|install|list|remove|listsources|installrepo] [args...]
#

set -e

# ============================================================================
# Configuration
# ============================================================================

WENGET_HOME="${HOME}/.wenget"
WENGET_APPS="${WENGET_HOME}/apps"
WENGET_BIN="${WENGET_HOME}/bin"
WENGET_CACHE="${WENGET_HOME}/cache"
WENGET_SCRIPT="${WENGET_APPS}/wenget/wenget.sh"
WENGET_BUCKET="https://raw.githubusercontent.com/superyngo/wenget-bucket/refs/heads/main/manifest.json"
SCRIPT_URL="https://raw.githubusercontent.com/superyngo/Wenget/main/scripts/wenget.sh"

# ============================================================================
# Colors
# ============================================================================

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${CYAN}${1}${RESET}"
}

log_success() {
    echo -e "${GREEN}✓${RESET} ${1}"
}

log_error() {
    echo -e "${RED}✗${RESET} ${1}" >&2
}

log_warn() {
    echo -e "${YELLOW}⚠${RESET} ${1}"
}

die() {
    log_error "$1"
    exit 1
}

# Detect platform (OS-ARCH-VARIANT)
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    # Convert architecture names
    case "$arch" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        armv7l|armv7) arch="armv7" ;;
        i686|i386) arch="i686" ;;
        *) die "Unsupported architecture: $arch" ;;
    esac

    # Detect libc variant for Linux
    if [ "$os" = "linux" ]; then
        # Check if musl is available (prefer musl over gnu)
        if ldd --version 2>&1 | grep -qi musl; then
            echo "${os}-${arch}-musl"
        else
            echo "${os}-${arch}-gnu"
        fi
    elif [ "$os" = "darwin" ]; then
        echo "macos-${arch}"
    else
        echo "${os}-${arch}"
    fi
}

# Check if command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
check_requirements() {
    local missing=()

    for cmd in curl tar gzip; do
        if ! has_command "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        die "Missing required tools: ${missing[*]}\nPlease install them first."
    fi

    # Warn about optional tools
    if ! has_command "jq"; then
        log_warn "jq not found. Some features may be limited."
        log_warn "Install jq for better experience: https://stedolan.github.io/jq/"
    fi
}

# Download file with progress
download_file() {
    local url=$1
    local output=$2

    if has_command "curl"; then
        curl -fsSL --progress-bar -o "$output" "$url"
    elif has_command "wget"; then
        wget -q --show-progress -O "$output" "$url"
    else
        die "Neither curl nor wget found"
    fi
}

# Extract archive
extract_archive() {
    local archive=$1
    local dest=$2

    mkdir -p "$dest"

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$dest"
            ;;
        *.tar.xz)
            if has_command "xz"; then
                tar -xJf "$archive" -C "$dest"
            else
                die "xz not found. Please install xz-utils to extract .tar.xz files"
            fi
            ;;
        *.tar.bz2)
            tar -xjf "$archive" -C "$dest"
            ;;
        *.zip)
            if has_command "unzip"; then
                unzip -q "$archive" -d "$dest"
            else
                die "unzip not found. Please install unzip to extract .zip files"
            fi
            ;;
        *)
            die "Unsupported archive format: $archive"
            ;;
    esac
}

# Find executable in directory
find_executable() {
    local dir=$1
    local name=$2

    # Try to find executable with matching name
    local found=$(find "$dir" -type f -executable -name "$name" 2>/dev/null | head -1)

    if [ -n "$found" ]; then
        echo "$found"
        return 0
    fi

    # Try without extension
    found=$(find "$dir" -type f -executable 2>/dev/null | grep -E "/${name}$" | head -1)

    if [ -n "$found" ]; then
        echo "$found"
        return 0
    fi

    # Fallback: find any executable
    found=$(find "$dir" -type f -executable 2>/dev/null | head -1)

    if [ -n "$found" ]; then
        echo "$found"
        return 0
    fi

    return 1
}

# Parse JSON without jq (fallback)
parse_json_simple() {
    local json=$1
    local key=$2

    echo "$json" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed "s/\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\"/\1/"
}

# ============================================================================
# Command: init
# ============================================================================

cmd_init() {
    log_info "Initializing Wenget..."

    check_requirements

    # Create directory structure
    log_info "Creating directories..."
    mkdir -p "$WENGET_APPS/wenget"
    mkdir -p "$WENGET_BIN"
    mkdir -p "$WENGET_CACHE"
    log_success "Created $WENGET_HOME"

    # Download script
    log_info "Downloading wenget.sh..."
    download_file "$SCRIPT_URL" "$WENGET_SCRIPT"
    chmod +x "$WENGET_SCRIPT"
    log_success "Installed to $WENGET_SCRIPT"

    # Create symlink
    ln -sf "../apps/wenget/wenget.sh" "$WENGET_BIN/wenget"
    log_success "Created symlink in $WENGET_BIN"

    # Add to PATH
    log_info "Adding to PATH..."
    local shell_config=""
    local shell_name=$(basename "$SHELL")

    case "$shell_name" in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                shell_config="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        zsh)
            shell_config="$HOME/.zshrc"
            ;;
        *)
            shell_config="$HOME/.profile"
            ;;
    esac

    if [ -n "$shell_config" ]; then
        if ! grep -q "$WENGET_BIN" "$shell_config" 2>/dev/null; then
            echo "" >> "$shell_config"
            echo "# Wenget" >> "$shell_config"
            echo "export PATH=\"\$HOME/.wenget/bin:\$PATH\"" >> "$shell_config"
            log_success "Added to $shell_config"
        else
            log_info "Already in PATH ($shell_config)"
        fi
    fi

    echo ""
    echo -e "${GREEN}${BOLD}Wenget installed successfully!${RESET}"
    echo ""
    echo "Run the following command to update your PATH:"
    echo -e "  ${CYAN}source $shell_config${RESET}"
    echo ""
    echo "Or restart your terminal."
    echo ""
    echo "Usage:"
    echo -e "  ${CYAN}wenget install <package>${RESET}    Install a package"
    echo -e "  ${CYAN}wenget list${RESET}                 List installed packages"
    echo -e "  ${CYAN}wenget remove <package>${RESET}     Remove a package"
    echo -e "  ${CYAN}wenget listsources${RESET}          List available packages"
    echo -e "  ${CYAN}wenget installrepo <url>${RESET}    Install from GitHub repo"
    echo ""
}

# ============================================================================
# Command: listsources
# ============================================================================

cmd_listsources() {
    log_info "Fetching available packages..."

    local platform=$(detect_platform)
    local manifest=$(curl -fsSL "$WENGET_BUCKET")

    if [ -z "$manifest" ]; then
        die "Failed to fetch package list"
    fi

    # Extract platform components (os-arch, ignore musl/gnu variant)
    local os=$(echo "$platform" | cut -d- -f1)
    local arch=$(echo "$platform" | cut -d- -f2)
    local platform_key="${os}-${arch}"

    echo ""
    echo -e "${BOLD}Available packages for ${CYAN}${platform_key}${RESET}:"
    echo ""

    if has_command "jq"; then
        # Use jq for better formatting
        echo "$manifest" | jq -r --arg platform "$platform_key" \
            '.packages[] | select(.platforms | has($platform)) |
            "  \u001b[32m•\u001b[0m \u001b[1m\(.name)\u001b[0m - \(.description)"'
    else
        # Fallback: simple grep parsing
        local count=0
        while IFS= read -r line; do
            if echo "$line" | grep -q "\"name\""; then
                local name=$(echo "$line" | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
                if [ -n "$name" ]; then
                    echo -e "  ${GREEN}•${RESET} ${BOLD}${name}${RESET}"
                    count=$((count + 1))
                fi
            fi
        done <<< "$manifest"

        if [ $count -eq 0 ]; then
            log_warn "No packages found (install jq for better results)"
        fi
    fi

    echo ""
}

# ============================================================================
# Command: install
# ============================================================================

cmd_install() {
    local package_name=$1

    if [ -z "$package_name" ]; then
        die "Usage: wenget install <package>"
    fi

    local platform=$(detect_platform)

    log_info "Installing ${BOLD}${package_name}${RESET} for ${platform}..."

    # Fetch manifest
    local manifest=$(curl -fsSL "$WENGET_BUCKET")

    if [ -z "$manifest" ]; then
        die "Failed to fetch package manifest"
    fi

    # Parse package info
    local download_url=""

    # Extract platform components (os-arch, ignore musl/gnu variant)
    local os=$(echo "$platform" | cut -d- -f1)
    local arch=$(echo "$platform" | cut -d- -f2)
    local platform_key="${os}-${arch}"

    if has_command "jq"; then
        download_url=$(echo "$manifest" | jq -r \
            --arg name "$package_name" \
            --arg platform "$platform_key" \
            '.packages[] | select(.name == $name) | .platforms[$platform].url // empty' 2>/dev/null)
    else
        log_warn "jq not found, using basic parsing (may be less reliable)"

        # Search for the package and then the platform-specific URL
        download_url=$(echo "$manifest" | \
            grep -A 50 "\"name\"[[:space:]]*:[[:space:]]*\"${package_name}\"" | \
            grep -A 5 "\"${platform_key}\"" | \
            grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | \
            sed 's/"url"[[:space:]]*:[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
    fi

    if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
        die "Package '$package_name' not found or not available for $platform"
    fi

    log_info "Download URL: $download_url"

    # Download
    local archive_name=$(basename "$download_url")
    local archive_path="$WENGET_CACHE/$archive_name"

    log_info "Downloading..."
    download_file "$download_url" "$archive_path"
    log_success "Downloaded"

    # Extract
    local extract_dir="$WENGET_CACHE/${package_name}-extract"
    rm -rf "$extract_dir"

    log_info "Extracting..."
    extract_archive "$archive_path" "$extract_dir"
    log_success "Extracted"

    # Find executable
    log_info "Finding executable..."
    local exe=$(find_executable "$extract_dir" "$package_name")

    if [ -z "$exe" ]; then
        # List files for debugging
        log_warn "Could not find executable automatically. Files extracted:"
        find "$extract_dir" -type f | head -10
        rm -rf "$extract_dir"
        die "Could not find executable for $package_name"
    fi

    log_info "Found: $(basename "$exe")"

    # Install
    local install_dir="$WENGET_APPS/$package_name"
    rm -rf "$install_dir"
    mkdir -p "$install_dir"

    # Copy entire directory structure or just the executable
    if [ -d "$(dirname "$exe")" ]; then
        cp -r "$(dirname "$exe")"/* "$install_dir/" 2>/dev/null || cp "$exe" "$install_dir/"
    fi

    chmod +x "$install_dir/$(basename "$exe")"

    # Create symlink
    ln -sf "../apps/$package_name/$(basename "$exe")" "$WENGET_BIN/$(basename "$exe")"

    # Cleanup
    rm -rf "$extract_dir"
    rm -f "$archive_path"

    log_success "Installed $package_name"
    echo ""
    echo -e "  Run: ${CYAN}$(basename "$exe") --help${RESET}"
    echo ""
}

# ============================================================================
# Command: list
# ============================================================================

cmd_list() {
    echo ""
    echo -e "${BOLD}Installed packages:${RESET}"
    echo ""

    local count=0
    for app in "$WENGET_APPS"/*; do
        if [ -d "$app" ]; then
            local name=$(basename "$app")
            if [ "$name" != "wenget" ]; then
                echo -e "  ${GREEN}•${RESET} ${name}"
                count=$((count + 1))
            fi
        fi
    done

    if [ $count -eq 0 ]; then
        echo -e "  ${YELLOW}No packages installed${RESET}"
    fi

    echo ""
}

# ============================================================================
# Command: remove
# ============================================================================

cmd_remove() {
    local package_name=$1

    if [ -z "$package_name" ]; then
        die "Usage: wenget remove <package>"
    fi

    local app_dir="$WENGET_APPS/$package_name"

    if [ ! -d "$app_dir" ]; then
        die "Package '$package_name' is not installed"
    fi

    log_info "Removing ${BOLD}${package_name}${RESET}..."

    # Remove app directory
    rm -rf "$app_dir"

    # Remove symlinks
    find "$WENGET_BIN" -type l | while read -r link; do
        if [ "$(readlink "$link" | grep -c "$package_name")" -gt 0 ]; then
            rm -f "$link"
        fi
    done

    log_success "Removed $package_name"
}

# ============================================================================
# Command: installrepo
# ============================================================================

cmd_installrepo() {
    local repo_url=$1

    if [ -z "$repo_url" ]; then
        die "Usage: wenget installrepo <github-url>"
    fi

    # Extract owner/repo from URL
    local repo=$(echo "$repo_url" | sed -n 's|.*github\.com/\([^/]*/[^/]*\).*|\1|p' | sed 's|\.git$||')

    if [ -z "$repo" ]; then
        die "Invalid GitHub URL: $repo_url"
    fi

    local package_name=$(basename "$repo")
    local platform=$(detect_platform)

    log_info "Installing ${BOLD}${package_name}${RESET} from ${repo}..."

    # Fetch latest release
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    log_info "Fetching release info..."

    local release=$(curl -fsSL "$api_url")

    if [ -z "$release" ]; then
        die "Failed to fetch release information"
    fi

    # Detect platform components
    local os=$(echo "$platform" | cut -d- -f1)
    local arch=$(echo "$platform" | cut -d- -f2)
    local variant=$(echo "$platform" | cut -d- -f3)

    # Convert arch to common names
    local arch_pattern="$arch"
    if [ "$arch" = "x86_64" ]; then
        arch_pattern="(x86_64|amd64|x64)"
    elif [ "$arch" = "aarch64" ]; then
        arch_pattern="(aarch64|arm64)"
    fi

    # Convert os to common names
    local os_pattern="$os"
    if [ "$os" = "macos" ]; then
        os_pattern="(macos|darwin|osx|mac)"
    fi

    # Find matching asset
    local download_url=""

    if has_command "jq"; then
        # Try with variant first, then without
        for try_variant in "$variant" ""; do
            local pattern="$os_pattern.*$arch_pattern"
            if [ -n "$try_variant" ]; then
                pattern="${pattern}.*${try_variant}"
            fi

            download_url=$(echo "$release" | jq -r --arg pat "$pattern" \
                '.assets[] | select(.name | test($pat; "i")) | .browser_download_url' | head -1)

            if [ -n "$download_url" ] && [ "$download_url" != "null" ]; then
                break
            fi
        done
    else
        # Fallback without jq
        log_warn "jq not found, using basic matching"
        download_url=$(echo "$release" | grep -i "browser_download_url" | \
                      grep -i "$os" | grep -iE "$arch_pattern" | \
                      sed -n 's/.*"browser_download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    fi

    if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
        log_error "No binary found for platform $platform"
        echo ""
        echo "Available assets:"
        if has_command "jq"; then
            echo "$release" | jq -r '.assets[].name'
        else
            echo "$release" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"name"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/'
        fi
        echo ""
        die "Installation failed"
    fi

    log_info "Found: $(basename "$download_url")"

    # Download and install (reuse install logic)
    local archive_name=$(basename "$download_url")
    local archive_path="$WENGET_CACHE/$archive_name"

    log_info "Downloading..."
    download_file "$download_url" "$archive_path"
    log_success "Downloaded"

    # Extract
    local extract_dir="$WENGET_CACHE/${package_name}-extract"
    rm -rf "$extract_dir"

    log_info "Extracting..."
    extract_archive "$archive_path" "$extract_dir"
    log_success "Extracted"

    # Find executable
    log_info "Finding executable..."
    local exe=$(find_executable "$extract_dir" "$package_name")

    if [ -z "$exe" ]; then
        log_warn "Could not find executable automatically. Extracted files:"
        find "$extract_dir" -type f -executable 2>/dev/null | head -10
        rm -rf "$extract_dir"
        die "Could not find executable for $package_name"
    fi

    log_info "Found: $(basename "$exe")"

    # Install
    local install_dir="$WENGET_APPS/$package_name"
    rm -rf "$install_dir"
    mkdir -p "$install_dir"

    if [ -d "$(dirname "$exe")" ]; then
        cp -r "$(dirname "$exe")"/* "$install_dir/" 2>/dev/null || cp "$exe" "$install_dir/"
    fi

    chmod +x "$install_dir/$(basename "$exe")"

    # Create symlink
    ln -sf "../apps/$package_name/$(basename "$exe")" "$WENGET_BIN/$(basename "$exe")"

    # Cleanup
    rm -rf "$extract_dir"
    rm -f "$archive_path"

    log_success "Installed $package_name from $repo"
    echo ""
    echo -e "  Run: ${CYAN}$(basename "$exe") --help${RESET}"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    local command=${1:-}

    case "$command" in
        init)
            cmd_init
            ;;
        install|add)
            shift
            cmd_install "$@"
            ;;
        list|ls)
            cmd_list
            ;;
        remove|del|rm)
            shift
            cmd_remove "$@"
            ;;
        listsources|search)
            cmd_listsources
            ;;
        installrepo)
            shift
            cmd_installrepo "$@"
            ;;
        help|--help|-h)
            echo "Wenget - Lightweight package manager for GitHub binaries"
            echo ""
            echo "Usage: wenget <command> [args...]"
            echo ""
            echo "Commands:"
            echo "  init                      Initialize wenget"
            echo "  install <package>         Install a package"
            echo "  list                      List installed packages"
            echo "  remove <package>          Remove a package"
            echo "  listsources               List available packages"
            echo "  installrepo <github-url>  Install from GitHub repository"
            echo ""
            echo "Aliases:"
            echo "  add, ls, del, rm, search"
            echo ""
            ;;
        *)
            if [ -z "$command" ]; then
                die "Usage: wenget <command> [args...]\nRun 'wenget help' for more information"
            else
                die "Unknown command: $command\nRun 'wenget help' for available commands"
            fi
            ;;
    esac
}

main "$@"
