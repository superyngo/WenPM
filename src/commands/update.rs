//! Update (Upgrade) command implementation

use crate::commands::add;
use crate::core::manifest::PackageSource;
use crate::core::Config;
use crate::providers::GitHubProvider;
use anyhow::Result;
use colored::Colorize;

/// Upgrade installed packages
pub fn run(names: Vec<String>, yes: bool) -> Result<()> {
    // Handle "wenget update self"
    if names.len() == 1 && names[0] == "self" {
        return upgrade_self();
    }

    let config = Config::new()?;
    let installed = config.get_or_create_installed()?;

    if installed.packages.is_empty() {
        println!("{}", "No packages installed".yellow());
        return Ok(());
    }

    // Create GitHub provider to fetch latest versions
    let github = GitHubProvider::new()?;

    // Determine which packages to upgrade
    let to_upgrade: Vec<String> = if names.is_empty() || (names.len() == 1 && names[0] == "all") {
        // List upgradeable packages
        let upgradeable = find_upgradeable(&config, &installed, &github)?;

        if upgradeable.is_empty() {
            println!("{}", "All packages are up to date".green());
            return Ok(());
        }

        println!("{}", "Packages to upgrade:".bold());
        for (name, current, latest) in &upgradeable {
            println!("  • {} {} -> {}", name, current.yellow(), latest.green());
        }
        println!();

        upgradeable.into_iter().map(|(name, _, _)| name).collect()
    } else {
        names
    };

    // Use add command to upgrade (reinstall)
    add::run(to_upgrade, yes)
}

/// Find upgradeable packages by checking their sources
fn find_upgradeable(
    config: &Config,
    installed: &crate::core::InstalledManifest,
    github: &GitHubProvider,
) -> Result<Vec<(String, String, String)>> {
    let mut upgradeable = Vec::new();

    for (name, inst_pkg) in &installed.packages {
        // Determine repo URL based on source
        let repo_url = match &inst_pkg.source {
            PackageSource::Bucket { name: bucket_name } => {
                // Get package info from cache for bucket packages
                let cache = config.get_or_rebuild_cache()?;

                // Find package in cache by name (cache is keyed by URL, not name)
                let found = cache
                    .packages
                    .values()
                    .find(|cached_pkg| cached_pkg.package.name == *name);

                if let Some(cached_pkg) = found {
                    cached_pkg.package.repo.clone()
                } else {
                    eprintln!(
                        "{} Package {} not found in bucket {} cache, skipping update check",
                        "Warning:".yellow(),
                        name,
                        bucket_name
                    );
                    continue;
                }
            }
            PackageSource::DirectRepo { url } => {
                // Use the stored repo URL directly
                url.clone()
            }
        };

        // Fetch latest version from GitHub
        if let Ok(latest_version) = github.fetch_latest_version(&repo_url) {
            if inst_pkg.version != latest_version {
                upgradeable.push((name.clone(), inst_pkg.version.clone(), latest_version));
            }
        }
    }

    Ok(upgradeable)
}

/// Upgrade wenget itself
fn upgrade_self() -> Result<()> {
    println!("{}", "Upgrading wenget...".cyan());

    // Get current version
    let current_version = env!("CARGO_PKG_VERSION");
    println!("Current version: {}", current_version);

    // Fetch latest release from GitHub
    let provider = GitHubProvider::new()?;
    let latest_version = provider.fetch_latest_version("https://github.com/superyngo/wenget")?;

    println!("Latest version: {}", latest_version);

    if current_version == latest_version {
        println!("{}", "✓ Already up to date".green());
        return Ok(());
    }

    println!();
    println!(
        "{}",
        "Self-upgrade functionality will be available in the next update".yellow()
    );
    println!("For now, please manually download and install the latest version from:");
    println!(
        "  {}",
        "https://github.com/superyngo/wenget/releases/latest".cyan()
    );

    Ok(())
}
