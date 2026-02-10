import 'package:flutter/widgets.dart' show SingleActivator;
import 'mac_menu_bar_platform_interface.dart';

/// No-op implementation of [MacMenuBarPlatform] for non-macOS platforms.
///
/// All methods are safe to call but do nothing. This allows consumers to
/// import and call `MacMenuBar` APIs on any platform without conditional
/// imports, while the actual native integration only activates on macOS.
class MacMenuBarNoop extends MacMenuBarPlatform {
  /// Registers this no-op implementation as the platform instance.
  ///
  /// Called automatically by Flutter's plugin registry on non-macOS platforms.
  static void registerWith() {
    MacMenuBarPlatform.instance = MacMenuBarNoop();
  }

  @override
  void setOnCutFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnCopyFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnPasteFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnSelectAllFromMenu(Future<bool> Function()? callback) {}

  @override
  Future<bool> addMenuItem({
    required String menuId,
    required String itemId,
    required String title,
    int? index,
    SingleActivator? shortcut,
    bool enabled = true,
  }) async => false;

  @override
  Future<bool> addSubmenu({
    required String parentMenuId,
    required String submenuId,
    required String title,
    int? index,
  }) async => false;

  @override
  Future<bool> removeMenuItem(String itemId) async => false;

  @override
  Future<bool> updateMenuItem({
    required String itemId,
    String? title,
    bool? enabled,
  }) async => false;

  @override
  Future<bool> setMenuItemEnabled(String itemId, bool enabled) async => false;

  @override
  void setMenuItemSelectedHandler(MenuItemSelectedHandler handler) {}
}
