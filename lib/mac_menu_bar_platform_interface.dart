import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show SingleActivator;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mac_menu_bar_method_channel.dart';
import 'mac_menu_bar_noop.dart';

/// The interface that implementations of `mac_menu_bar` must implement.
///
/// Platform-specific implementations should extend this class instead of directly
/// extending [PlatformInterface] to ensure they are using the correct platform
/// interface for functionality that depends on the platform's implementation.
abstract class MacMenuBarPlatform extends PlatformInterface {
  /// Constructs a MacMenuBarPlatform.
  MacMenuBarPlatform() : super(token: _token);

  /// The token used to verify that platform implementations extend this class
  static final Object _token = Object();

  /// The default instance of [MacMenuBarPlatform] to use.
  ///
  /// Defaults to [MethodChannelMacMenuBar] on macOS,
  /// or [MacMenuBarNoop] in release mode on non-macOS platforms.
  static MacMenuBarPlatform _instance =
      (defaultTargetPlatform == TargetPlatform.macOS || kDebugMode)
          ? MethodChannelMacMenuBar()
          : MacMenuBarNoop();

  /// Returns the current platform instance.
  ///
  /// This getter returns the current platform implementation, which defaults to
  /// [MethodChannelMacMenuBar] on macOS, or [MacMenuBarNoop] on non-macOS platforms.
  static MacMenuBarPlatform get instance => _instance;

  /// Sets the platform instance that will be used by the plugin.
  ///
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MacMenuBarPlatform] when
  /// they register themselves.
  ///
  /// Throws an [AssertionError] if the provided instance does not extend
  /// [MacMenuBarPlatform].
  static set instance(MacMenuBarPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sets the callback that will be invoked when the Cut menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnCutFromMenu(Future<bool> Function()? callback);

  /// Sets the callback that will be invoked when the Copy menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnCopyFromMenu(Future<bool> Function()? callback);

  /// Sets the callback that will be invoked when the Paste menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnPasteFromMenu(Future<bool> Function()? callback);

  /// Sets the callback that will be invoked when the Select All menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnSelectAllFromMenu(Future<bool> Function()? callback);

  /// Adds a menu item to the specified menu.
  ///
  /// [menuId] is the identifier of the menu to add the item to (e.g., "main", "File", etc.).
  /// [itemId] is a unique identifier for this menu item.
  /// [title] is the display text for the menu item.
  /// [index] is the optional position to insert the item (null to append).
  /// [shortcut] is the optional keyboard shortcut using [SingleActivator].
  /// [enabled] determines whether the menu item is initially enabled.
  ///
  /// Returns `true` if the menu item was successfully added.
  Future<bool> addMenuItem({
    required String menuId,
    required String itemId,
    required String title,
    int? index,
    SingleActivator? shortcut,
    bool enabled = true,
  });

  /// Adds a submenu to the specified parent menu.
  ///
  /// [parentMenuId] is the identifier of the parent menu to add the submenu to.
  /// [submenuId] is a unique identifier for this submenu (used to add items to it later).
  /// [title] is the display text for the submenu.
  /// [index] is the optional position to insert the submenu (null to append).
  ///
  /// Returns `true` if the submenu was successfully added.
  Future<bool> addSubmenu({
    required String parentMenuId,
    required String submenuId,
    required String title,
    int? index,
  });

  /// Removes a menu item by its ID.
  ///
  /// [itemId] is the identifier of the menu item to remove.
  ///
  /// Returns `true` if the menu item was successfully removed.
  Future<bool> removeMenuItem(String itemId);

  /// Updates a menu item's properties.
  ///
  /// [itemId] is the identifier of the menu item to update.
  /// [title] is the new title (null to keep current).
  /// [enabled] is the new enabled state (null to keep current).
  ///
  /// Returns `true` if the menu item was successfully updated.
  Future<bool> updateMenuItem({
    required String itemId,
    String? title,
    bool? enabled,
  });

  /// Sets a menu item's enabled state.
  ///
  /// [itemId] is the identifier of the menu item.
  /// [enabled] is the new enabled state.
  ///
  /// Returns `true` if the menu item's state was successfully updated.
  Future<bool> setMenuItemEnabled(String itemId, bool enabled);

  /// Sets the callback handler for custom menu item selections.
  ///
  /// The handler receives the item ID when a custom menu item is selected.
  void setMenuItemSelectedHandler(MenuItemSelectedHandler handler);
}

/// Handler for custom menu item selections.
///
/// Receives the [itemId] of the selected menu item.
typedef MenuItemSelectedHandler = void Function(String itemId);

/// Extension to convert SingleActivator to platform-specific data.
extension SingleActivatorExtension on SingleActivator {
  /// Converts the SingleActivator to a map for method channel communication.
  Map<String, dynamic> toMap() {
    final modifiers = <String>[];

    if (control) modifiers.add('control');
    if (shift) modifiers.add('shift');
    if (alt) modifiers.add('option');
    if (meta) modifiers.add('command');

    String keyEquivalent = _logicalKeyToString(trigger);

    return {'keyEquivalent': keyEquivalent, 'keyModifiers': modifiers};
  }

  /// Converts a LogicalKeyboardKey to a string suitable for macOS menu shortcuts.
  String _logicalKeyToString(LogicalKeyboardKey key) {
    // Handle letter keys
    if (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
        key.keyId <= LogicalKeyboardKey.keyZ.keyId) {
      final char = String.fromCharCode(
        'a'.codeUnitAt(0) + (key.keyId - LogicalKeyboardKey.keyA.keyId),
      );
      return char;
    }

    // Handle number keys
    if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      return (key.keyId - LogicalKeyboardKey.digit0.keyId).toString();
    }

    // Handle special keys
    if (key == LogicalKeyboardKey.comma) return ',';
    if (key == LogicalKeyboardKey.period) return '.';
    if (key == LogicalKeyboardKey.slash) return '/';
    if (key == LogicalKeyboardKey.semicolon) return ';';
    if (key == LogicalKeyboardKey.quote) return "'";
    if (key == LogicalKeyboardKey.bracketLeft) return '[';
    if (key == LogicalKeyboardKey.bracketRight) return ']';
    if (key == LogicalKeyboardKey.backslash) return '\\';
    if (key == LogicalKeyboardKey.minus) return '-';
    if (key == LogicalKeyboardKey.equal) return '=';
    if (key == LogicalKeyboardKey.backquote) return '`';

    // Handle function keys
    if (key == LogicalKeyboardKey.f1) return '\u{F704}';
    if (key == LogicalKeyboardKey.f2) return '\u{F705}';
    if (key == LogicalKeyboardKey.f3) return '\u{F706}';
    if (key == LogicalKeyboardKey.f4) return '\u{F707}';
    if (key == LogicalKeyboardKey.f5) return '\u{F708}';
    if (key == LogicalKeyboardKey.f6) return '\u{F709}';
    if (key == LogicalKeyboardKey.f7) return '\u{F70A}';
    if (key == LogicalKeyboardKey.f8) return '\u{F70B}';
    if (key == LogicalKeyboardKey.f9) return '\u{F70C}';
    if (key == LogicalKeyboardKey.f10) return '\u{F70D}';
    if (key == LogicalKeyboardKey.f11) return '\u{F70E}';
    if (key == LogicalKeyboardKey.f12) return '\u{F70F}';

    // Handle special navigation keys
    if (key == LogicalKeyboardKey.delete) return '\u{0008}';
    if (key == LogicalKeyboardKey.escape) return '\u{001B}';
    if (key == LogicalKeyboardKey.tab) return '\u{0009}';
    if (key == LogicalKeyboardKey.enter) return '\u{000D}';
    if (key == LogicalKeyboardKey.arrowLeft) return '\u{F702}';
    if (key == LogicalKeyboardKey.arrowRight) return '\u{F703}';
    if (key == LogicalKeyboardKey.arrowUp) return '\u{F700}';
    if (key == LogicalKeyboardKey.arrowDown) return '\u{F701}';

    return '';
  }
}
