//! Package resolver - Smart detection and resolution of package inputs
//!
//! This module provides utilities for:
//! - Detecting whether an input is a package name or GitHub URL
//! - Fetching package information from cache or GitHub
//! - Determining the bucket source of cached packages

use crate::core::manifest::{Package, PackageSource};
use crate::core::Config;
use crate::providers::{GitHubProvider, SourceProvider};
use anyhow::{anyhow, Context, Result};

/// Represents the type of package input
#[derive(Debug, Clone)]
pub enum PackageInput {
    /// Package name from cache (supports glob patterns)
    CacheName(String),
    /// Direct GitHub repository URL
    DirectUrl(String),
}

impl PackageInput {
    /// Parse an input string and detect if it's a URL or package name
    pub fn parse(input: &str) -> Self {
        // Check if input looks like a URL
        if input.starts_with("http://")
            || input.starts_with("https://")
            || input.starts_with("github.com/")
        {
            Self::DirectUrl(normalize_github_url(input))
        } else {
            Self::CacheName(input.to_string())
        }
    }
}

/// Normalize GitHub URL to standard format
fn normalize_github_url(url: &str) -> String {
    let url = url.trim();

    // Add https:// if missing
    if url.starts_with("github.com/") {
        return format!("https://{}", url);
    }

    url.to_string()
}

/// Result of package resolution with source information
#[derive(Debug, Clone)]
pub struct ResolvedPackage {
    /// The package information
    pub package: Package,
    /// The source of this package
    pub source: PackageSource,
}

impl ResolvedPackage {
    /// Create a new resolved package
    pub fn new(package: Package, source: PackageSource) -> Self {
        Self { package, source }
    }
}

/// Package resolver for fetching package information
pub struct PackageResolver {
    config: Config,
    github: GitHubProvider,
}

impl PackageResolver {
    /// Create a new package resolver
    pub fn new(config: Config) -> Result<Self> {
        let github = GitHubProvider::new()?;
        Ok(Self { config, github })
    }

    /// Resolve package(s) from input
    ///
    /// Returns a list of resolved packages with their sources.
    /// For cache names, supports glob patterns and may return multiple matches.
    /// For URLs, returns a single package.
    pub fn resolve(&self, input: &PackageInput) -> Result<Vec<ResolvedPackage>> {
        match input {
            PackageInput::CacheName(name) => self.resolve_from_cache(name),
            PackageInput::DirectUrl(url) => {
                let pkg = self.resolve_from_url(url)?;
                Ok(vec![pkg])
            }
        }
    }

    /// Resolve package from cache (supports glob patterns)
    /// Falls back to checking installed packages if not found in cache
    fn resolve_from_cache(&self, name: &str) -> Result<Vec<ResolvedPackage>> {
        // Load cache
        let cache = self.config.get_or_rebuild_cache()?;

        // Filter packages by name pattern
        let matches: Vec<_> = if name.contains('*') {
            // Glob pattern matching
            cache
                .packages
                .values()
                .filter(|cached| glob_match(&cached.package.name, name))
                .collect()
        } else {
            // Exact name matching
            cache
                .packages
                .values()
                .filter(|cached| cached.package.name == name)
                .collect()
        };

        if !matches.is_empty() {
            // Found in cache - return these matches
            return Ok(matches
                .into_iter()
                .map(|cached| ResolvedPackage::new(cached.package.clone(), cached.source.clone()))
                .collect());
        }

        // Not found in cache - check if it's an installed package from direct URL
        // Note: Only check for exact name match, not glob patterns
        if !name.contains('*') {
            let installed = self.config.get_or_create_installed()?;
            if let Some(inst_pkg) = installed.get_package(name) {
                // Check if it's a DirectRepo source
                if let PackageSource::DirectRepo { url } = &inst_pkg.source {
                    // Fetch the package info from the URL
                    return self.resolve_from_url(url).map(|pkg| vec![pkg]);
                }
            }
        }

        Err(anyhow!("No packages found matching: {}", name))
    }

    /// Resolve package from GitHub URL
    fn resolve_from_url(&self, url: &str) -> Result<ResolvedPackage> {
        let package = self
            .github
            .fetch_package(url)
            .with_context(|| format!("Failed to fetch package from: {}", url))?;

        let source = PackageSource::DirectRepo {
            url: url.to_string(),
        };

        Ok(ResolvedPackage::new(package, source))
    }

    /// Get the latest version from GitHub for a package
    pub fn fetch_latest_version(&self, repo_url: &str) -> Result<String> {
        self.github.fetch_latest_version(repo_url)
    }
}

/// Simple glob pattern matching (supports * wildcard)
fn glob_match(text: &str, pattern: &str) -> bool {
    // Split pattern by '*'
    let parts: Vec<&str> = pattern.split('*').collect();

    if parts.len() == 1 {
        // No wildcard, exact match
        return text == pattern;
    }

    let mut pos = 0;

    for (i, part) in parts.iter().enumerate() {
        if part.is_empty() {
            continue;
        }

        if i == 0 {
            // First part must match start
            if !text.starts_with(part) {
                return false;
            }
            pos = part.len();
        } else if i == parts.len() - 1 {
            // Last part must match end
            if !text[pos..].ends_with(part) {
                return false;
            }
        } else {
            // Middle parts must exist in order
            if let Some(found_pos) = text[pos..].find(part) {
                pos += found_pos + part.len();
            } else {
                return false;
            }
        }
    }

    true
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_package_input() {
        assert!(matches!(
            PackageInput::parse("ripgrep"),
            PackageInput::CacheName(_)
        ));
        assert!(matches!(
            PackageInput::parse("https://github.com/user/repo"),
            PackageInput::DirectUrl(_)
        ));
        assert!(matches!(
            PackageInput::parse("github.com/user/repo"),
            PackageInput::DirectUrl(_)
        ));
    }

    #[test]
    fn test_normalize_github_url() {
        assert_eq!(
            normalize_github_url("github.com/user/repo"),
            "https://github.com/user/repo"
        );
        assert_eq!(
            normalize_github_url("https://github.com/user/repo"),
            "https://github.com/user/repo"
        );
    }

    #[test]
    fn test_glob_match() {
        assert!(glob_match("ripgrep", "ripgrep"));
        assert!(glob_match("ripgrep", "rip*"));
        assert!(glob_match("ripgrep", "*grep"));
        assert!(glob_match("ripgrep", "r*p*p"));
        assert!(glob_match("ripgrep", "*"));

        assert!(!glob_match("ripgrep", "rip"));
        assert!(!glob_match("ripgrep", "grep"));
        assert!(!glob_match("ripgrep", "bat*"));
    }
}
