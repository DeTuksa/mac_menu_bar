import 'package:flutter/widgets.dart' show SingleActivator;

import 'mac_menu_bar_platform_interface.dart';

/// A plugin that provides access to macOS menu bar actions in Flutter applications.
///
/// This class allows you to handle standard menu bar actions (Cut, Copy, Paste, Select All)
/// in your Flutter application on macOS. You can register callbacks that will be invoked
/// when the corresponding menu items are selected in the system menu bar.
///
/// ## Usage
///
/// ```dart
/// // Set up menu bar action handlers
/// MacMenuBar.onCut(() async {
///   // Handle cut action
///   return true; // Return true to indicate the action was handled
/// });
///
/// MacMenuBar.onCopy(() async {
///   // Handle copy action
///   return true; // Return false to allow default system behavior
/// });
/// ```
class MacMenuBar {
  /// Returns the singleton instance of [MacMenuBar].
  static MacMenuBarPlatform get instance => MacMenuBarPlatform.instance;

  /// Registers a callback to be invoked when the Cut menu item is selected.
  ///
  /// The [handler] should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Example:
  /// ```dart
  /// MacMenuBar.onCut(() async {
  ///   // Handle cut operation
  ///   return true; // Return true to indicate the action was handled
  /// });
  /// ```
  static void onCut(Future<bool> Function() handler) =>
      instance.setOnCutFromMenu(handler);

  /// Registers a callback to be invoked when the Copy menu item is selected.
  ///
  /// The [handler] should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Example:
  /// ```dart
  /// MacMenuBar.onCopy(() async {
  ///   // Handle copy operation
  ///   return true; // Return true to indicate the action was handled
  /// });
  /// ```
  static void onCopy(Future<bool> Function() handler) =>
      instance.setOnCopyFromMenu(handler);

  /// Registers a callback to be invoked when the Paste menu item is selected.
  ///
  /// The [handler] should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Example:
  /// ```dart
  /// MacMenuBar.onPaste(() async {
  ///   // Handle paste operation
  ///   return true; // Return true to indicate the action was handled
  /// });
  /// ```
  static void onPaste(Future<bool> Function() handler) =>
      instance.setOnPasteFromMenu(handler);

  /// Registers a callback to be invoked when the Select All menu item is selected.
  ///
  /// The [handler] should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Example:
  /// ```dart
  /// MacMenuBar.onSelectAll(() async {
  ///   // Handle select all operation
  ///   return true; // Return true to indicate the action was handled
  /// });
  /// ```
  static void onSelectAll(Future<bool> Function() handler) =>
      MacMenuBarPlatform.instance.setOnSelectAllFromMenu(handler);

  /// Adds a menu item to the specified menu.
  ///
  /// [menuId] identifies the menu to add the item to. Common menu IDs include:
  /// - "main" - The main menu bar
  /// - "File" - The File menu
  /// - "Edit" - The Edit menu
  /// - "View" - The View menu
  /// - "Window" - The Window menu
  /// - "Help" - The Help menu
  /// - Custom submenu IDs that you've created
  ///
  /// [itemId] is a unique identifier for this menu item. You'll receive this ID
  /// in your [MenuItemSelectedHandler] when the item is selected.
  ///
  /// [title] is the display text for the menu item.
  ///
  /// [index] is the optional position to insert the item. If null, the item is
  /// appended to the end of the menu.
  ///
  /// [shortcut] is the optional keyboard shortcut using [SingleActivator].
  /// Use [meta] for Command (⌘), [shift] for Shift (⇧), [alt] for Option (⌥),
  /// and [control] for Control (⌃).
  ///
  /// [enabled] determines whether the menu item is initially enabled.
  ///
  /// Returns `true` if the menu item was successfully added.
  ///
  /// Example:
  /// ```dart
  /// // Add menu item with Cmd+Shift+S shortcut
  /// await MacMenuBar.instance.addMenuItem(
  ///   menuId: 'File',
  ///   itemId: 'save_as',
  ///   title: 'Save As...',
  ///   shortcut: const SingleActivator(
  ///     LogicalKeyboardKey.keyS,
  ///     meta: true,
  ///     shift: true,
  ///   ),
  /// );
  ///
  /// // Add menu item with Cmd+, shortcut (preferences)
  /// await MacMenuBar.instance.addMenuItem(
  ///   menuId: 'File',
  ///   itemId: 'preferences',
  ///   title: 'Preferences...',
  ///   shortcut: const SingleActivator(
  ///     LogicalKeyboardKey.comma,
  ///     meta: true,
  ///   ),
  /// );
  /// ```
  static Future<bool> addMenuItem({
    required String menuId,
    required String itemId,
    required String title,
    int? index,
    SingleActivator? shortcut,
    bool enabled = true,
  }) {
    return instance.addMenuItem(
      menuId: menuId,
      itemId: itemId,
      title: title,
      index: index,
      shortcut: shortcut,
      enabled: enabled,
    );
  }

  /// Adds a submenu to the specified parent menu.
  ///
  /// [parentMenuId] identifies the parent menu. This can be "main" for the main
  /// menu bar, or any existing menu ID.
  ///
  /// [submenuId] is a unique identifier for the new submenu. You'll use this ID
  /// when adding items to this submenu.
  ///
  /// [title] is the display text for the submenu.
  ///
  /// [index] is the optional position to insert the submenu. If null, the submenu
  /// is appended to the end of the parent menu.
  ///
  /// Returns `true` if the submenu was successfully added.
  ///
  /// Example:
  /// ```dart
  /// // Create a submenu in the main menu bar
  /// await MacMenuBar.instance.addSubmenu(
  ///   parentMenuId: 'main',
  ///   submenuId: 'tools',
  ///   title: 'Tools',
  /// );
  ///
  /// // Add items to the submenu
  /// await MacMenuBar.instance.addMenuItem(
  ///   menuId: 'tools',
  ///   itemId: 'tool1',
  ///   title: 'Tool 1',
  ///   shortcut: const SingleActivator(
  ///     LogicalKeyboardKey.digit1,
  ///     meta: true,
  ///     alt: true,
  ///   ),
  /// );
  /// ```
  static Future<bool> addSubmenu({
    required String parentMenuId,
    required String submenuId,
    required String title,
    int? index,
  }) {
    return instance.addSubmenu(
      parentMenuId: parentMenuId,
      submenuId: submenuId,
      title: title,
      index: index,
    );
  }

  /// Removes a menu item by its ID.
  ///
  /// [itemId] is the identifier of the menu item to remove. This works for both
  /// regular menu items and submenus.
  ///
  /// Returns `true` if the menu item was successfully removed.
  ///
  /// Example:
  /// ```dart
  /// await MacMenuBar.instance.removeMenuItem('save_as');
  /// ```
  static Future<bool> removeMenuItem(String itemId) {
    return instance.removeMenuItem(itemId);
  }

  /// Updates a menu item's properties.
  ///
  /// [itemId] is the identifier of the menu item to update.
  ///
  /// [title] is the new title. If null, the title is not changed.
  ///
  /// [enabled] is the new enabled state. If null, the enabled state is not changed.
  ///
  /// Returns `true` if the menu item was successfully updated.
  ///
  /// Example:
  /// ```dart
  /// // Change the title
  /// await MacMenuBar.instance.updateMenuItem(
  ///   itemId: 'save_as',
  ///   title: 'Save Copy As...',
  /// );
  ///
  /// // Disable the item
  /// await MacMenuBar.instance.updateMenuItem(
  ///   itemId: 'save_as',
  ///   enabled: false,
  /// );
  /// ```
  static Future<bool> updateMenuItem({
    required String itemId,
    String? title,
    bool? enabled,
  }) {
    return instance.updateMenuItem(
      itemId: itemId,
      title: title,
      enabled: enabled,
    );
  }

  /// Sets a menu item's enabled state.
  ///
  /// This is a convenience method for quickly enabling or disabling a menu item
  /// without changing other properties.
  ///
  /// [itemId] is the identifier of the menu item.
  ///
  /// [enabled] is the new enabled state.
  ///
  /// Returns `true` if the menu item's state was successfully updated.
  ///
  /// Example:
  /// ```dart
  /// // Disable a menu item
  /// await MacMenuBar.instance.setMenuItemEnabled('save_as', false);
  ///
  /// // Enable it again
  /// await MacMenuBar.instance.setMenuItemEnabled('save_as', true);
  /// ```
  static Future<bool> setMenuItemEnabled(String itemId, bool enabled) {
    return instance.setMenuItemEnabled(itemId, enabled);
  }

  /// Sets the callback handler for custom menu item selections.
  ///
  /// The [handler] function will be called when the user selects a custom menu item
  /// that was added using [addMenuItem]. The handler receives the item's ID.
  ///
  /// Example:
  /// ```dart
  /// MacMenuBar.instance.setMenuItemSelectedHandler((itemId) {
  ///   switch (itemId) {
  ///     case 'new_document':
  ///       createNewDocument();
  ///       break;
  ///     case 'open_preferences':
  ///       openPreferences();
  ///       break;
  ///   }
  /// });
  /// ```
  static void setMenuItemSelectedHandler(MenuItemSelectedHandler handler) {
    instance.setMenuItemSelectedHandler(handler);
  }
}
