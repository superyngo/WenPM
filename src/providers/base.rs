//! Base trait for source providers

use crate::core::Package;
use anyhow::Result;

/// Trait for source providers (GitHub, GitLab, etc.)
pub trait SourceProvider {
    /// Extract package information from a repository URL
    ///
    /// # Arguments
    /// * `url` - Repository URL (e.g., "https://github.com/user/repo")
    ///
    /// # Returns
    /// Package metadata with latest release information
    fn fetch_package(&self, url: &str) -> Result<Package>;

    /// Get the provider name
    #[allow(dead_code)]
    fn name(&self) -> &str;
}
