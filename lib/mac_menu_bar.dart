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
      MacMenuBarPlatform.instance.setOnCutFromMenu(handler);

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
      MacMenuBarPlatform.instance.setOnCopyFromMenu(handler);

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
      MacMenuBarPlatform.instance.setOnPasteFromMenu(handler);

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
}
