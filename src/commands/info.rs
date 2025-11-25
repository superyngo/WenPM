//! Info command implementation
//!
//! Shows detailed package information from cache (with glob support) or GitHub URL

use crate::core::Config;
use crate::package_resolver::{PackageInput, PackageResolver, ResolvedPackage};
use anyhow::Result;
use colored::Colorize;

/// Show package information
pub fn run(names: Vec<String>) -> Result<()> {
    let config = Config::new()?;
    let resolver = PackageResolver::new(Config::new()?)?;

    if names.is_empty() {
        println!("{}", "No package names or URLs provided".yellow());
        println!("Usage: wenget info <name|url> [<name|url>...]");
        println!();
        println!("Examples:");
        println!("  wenget info ripgrep              # Query from cache");
        println!("  wenget info 'rip*'               # Glob pattern (cache only)");
        println!("  wenget info https://github.com/BurntSushi/ripgrep  # Direct URL");
        return Ok(());
    }

    // Load installed packages for status checking
    let installed = config.get_or_create_installed()?;

    let mut total_found = 0;

    for name in &names {
        let input = PackageInput::parse(name);

        match resolver.resolve(&input) {
            Ok(packages) => {
                for resolved in packages {
                    if total_found > 0 {
                        println!();
                        println!("{}", "─".repeat(80));
                        println!();
                    }
                    display_package_info(&resolved, &installed, &resolver)?;
                    total_found += 1;
                }
            }
            Err(e) => {
                eprintln!("{} {}: {}", "Error".red().bold(), name, e);
            }
        }
    }

    if total_found == 0 {
        println!("{}", "No packages found".yellow());
    } else if total_found > 1 {
        println!();
        println!(
            "{}",
            format!("Found {} package(s)", total_found).green().bold()
        );
    }

    Ok(())
}

/// Display detailed information for a single package
fn display_package_info(
    resolved: &ResolvedPackage,
    installed: &crate::core::InstalledManifest,
    resolver: &PackageResolver,
) -> Result<()> {
    let pkg = &resolved.package;

    // Header
    println!("{}", pkg.name.bold().cyan());
    println!("{}", "─".repeat(60));

    // Basic info
    println!("{:<16} {}", "Repository:".bold(), pkg.repo);

    if let Some(ref homepage) = pkg.homepage {
        println!("{:<16} {}", "Homepage:".bold(), homepage);
    }

    if let Some(ref license) = pkg.license {
        println!("{:<16} {}", "License:".bold(), license);
    }

    println!("{:<16} {}", "Description:".bold(), pkg.description);

    // Source
    match &resolved.source {
        crate::core::manifest::PackageSource::Bucket { name } => {
            println!("{:<16} {} ({})", "Source:".bold(), "Bucket".green(), name);
        }
        crate::core::manifest::PackageSource::DirectRepo { url: _ } => {
            println!("{:<16} {}", "Source:".bold(), "Direct URL".yellow());
        }
    }

    // Latest version from GitHub
    if let Ok(version) = resolver.fetch_latest_version(&pkg.repo) {
        println!("{:<16} {}", "Latest version:".bold(), version.green());
    }

    // Installation status
    if let Some(inst_pkg) = installed.get_package(&pkg.name) {
        println!(
            "{:<16} {} (v{})",
            "Status:".bold(),
            "Installed".green(),
            inst_pkg.version
        );
        println!("{:<16} {}", "Installed at:".bold(), inst_pkg.installed_at);
        println!("{:<16} {}", "Platform:".bold(), inst_pkg.platform);
        println!("{:<16} {}", "Install path:".bold(), inst_pkg.install_path);
    } else {
        println!("{:<16} {}", "Status:".bold(), "Not installed".yellow());
    }

    // Supported platforms
    println!();
    println!(
        "{} {} platform(s)",
        "Supported platforms:".bold(),
        pkg.platforms.len()
    );
    let mut platforms: Vec<_> = pkg.platforms.keys().collect();
    platforms.sort();

    for platform in platforms {
        let binary = &pkg.platforms[platform];
        let size_mb = binary.size as f64 / 1024.0 / 1024.0;
        println!("  {} {:<25} ({:.2} MB)", "•".cyan(), platform, size_mb);
    }

    Ok(())
}
