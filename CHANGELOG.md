# Changelog

## [0.0.3] - 2026-02-10

### Added

- Multi-platform support for static analysis compatibility
- No-op implementation for non-macOS platforms to prevent MissingPluginException
- Platform detection in method channel implementation
- Safe API calls that return false on non-macOS platforms
- Web platform implementation with proper plugin registration

### Changed

- Modified method channel implementation to gracefully handle non-macOS platforms
- Updated pubspec.yaml to support multi-platform development workflows
- Improved cross-platform compatibility for dependent packages
- Enhanced platform interface with automatic implementation selection

### Fixed

- Fixed pana analyzer marking packages as macOS-only when depending on mac_menu_bar
- Resolved MissingPluginException on non-macOS platforms
- Eliminated static analysis restrictions for multi-platform packages
- Fixed web platform registration and plugin resolution issues

### Credits

Special thanks to @csells (https://github.com/csells) for identifying and helping resolve platform registration issues and providing valuable insights into Flutter plugin architecture patterns.

## [0.0.2] - 2026-01-11

### Added

- Support for adding custom menu items with keyboard shortcuts
- `addMenuItem` method for programmatically adding menu items
- `addSubmenu` method for creating nested menu structures
- `removeMenuItem` method for removing menu items
- `setMenuItemEnabled` method for toggling menu item state
- `updateMenuItem` method for modifying existing menu items
- `setMenuItemSelectedHandler` for handling custom menu item selections

### Changed

- Improved error handling and logging
- Enhanced documentation with comprehensive API references
- Refactored platform channel implementation for better maintainability
- Optimized menu item management

### Fixed

- Fixed issues with menu item state management
- Resolved potential memory leaks in native code
- Fixed keyboard shortcut handling for special characters

## [0.0.1] - 2025-12-18

- Initial development release
- Initial release of the Mac Menu Bar plugin
- Support for handling standard menu bar actions: Cut, Copy, Paste, and Select All
- Platform interface for macOS menu bar integration
- Method channel implementation for Flutter to native communication
- Example application demonstrating usage
- Comprehensive documentation and API references
- Improved error handling and fallback to system defaults
- Optimized menu item override mechanism
- Enhanced code documentation and examples
