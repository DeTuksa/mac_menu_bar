# Changelog

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
