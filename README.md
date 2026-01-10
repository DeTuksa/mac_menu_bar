# Mac Menu Bar Plugin for Flutter

[![pub package](https://img.shields.io/pub/v/mac_menu_bar.svg)](https://pub.dev/packages/mac_menu_bar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin that provides access to macOS menu bar actions, allowing Flutter applications to handle standard menu items like Cut, Copy, Paste, and Select All.

![Screenshot](readme/screenshot.jpeg)

## Features

- Intercept Standard Menu Actions: Handle Cut, Copy, Paste, and Select All from the macOS menu bar
- Custom Menu Items: Add your own menu items to existing menus or create new ones
- Submenu Support: Create nested menu structures with unlimited depth
- Keyboard Shortcuts: Define shortcuts using Flutter's SingleActivator class
- Clean API: Type-safe, well-documented API following Flutter best practices
- Fallback Support: Automatically falls back to system behavior when actions aren't handled

## Installation

Add `mac_menu_bar` to your `pubspec.yaml` file:

```yaml
dependencies:
  mac_menu_bar: ^0.0.2
```

Then run `flutter pub get` to install the package.

## Usage

### Basic Setup

Import the package in your Dart code:

```dart
import 'package:mac_menu_bar/mac_menu_bar.dart';
```

### Handling Menu Actions

Set up handlers for the menu actions in your app's initialization:

```dart
@override
void initState() {
  super.initState();
  
  // Handle Cut menu item
  MacMenuBar.onCut(() async {
    debugPrint('Cut menu item selected');
    // Implement your cut logic here
    return true; // Return true to indicate the action was handled
  });

  // Handle Copy menu item
  MacMenuBar.onCopy(() async {
    debugPrint('Copy menu item selected');
    // Implement your copy logic here
    return true;
  });

  // Handle Paste menu item
  MacMenuBar.onPaste(() async {
    debugPrint('Paste menu item selected');
    // Implement your paste logic here
    return true;
  });

  // Handle Select All menu item
  MacMenuBar.onSelectAll(() async {
    debugPrint('Select All menu item selected');
    // Implement your select all logic here
    return true;
  });
}
```

### Handling Menu Actions Selectively

Return `false` from a handler to let the system handle the action:

```dart
MacMenuBar.onPaste(() async {
  if (shouldHandlePaste) {
    // Handle paste operation
    return true;
  }
  // Let the system handle the paste operation
  return false;
});
```

### Adding Custom Menu Items
You can add custom menu items to existing menus or create new ones:

```dart
await MacMenuBar.addMenuItem(
  menuId: 'View',
  itemId: 'refresh',
  title: 'Refresh',
);
```

### Creating Submenus
You can create submenus with unlimited depth:
```dart
// Create a custom submenu in the main menu bar
await MacMenuBar.addSubmenu(
  parentMenuId: 'main',
  submenuId: 'tools',
  title: 'Tools',
);

// Add items to the submenu
await MacMenuBar.addMenuItem(
  menuId: 'tools',
  itemId: 'tool_1',
  title: 'Developer Tools',
  shortcut: const SingleActivator(
    LogicalKeyboardKey.digit1,
    meta: true,
    alt: true,
  ),
);
```

## Platform Support

This plugin is only supported on macOS. It will have no effect on other platforms.

## Example

For a complete example, see the `example` directory in this repository.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

