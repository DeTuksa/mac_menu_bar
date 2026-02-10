import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/widgets.dart' show SingleActivator;
import 'mac_menu_bar_platform_interface.dart';

/// Web implementation of [MacMenuBarPlatform].
///
/// This is a no-op implementation since macOS native menus don't exist on web.
/// All methods are safe to call but do nothing.
class MacMenuBarWebPlugin extends MacMenuBarPlatform {
  /// Registers this web implementation.
  static void registerWith(Registrar registrar) {
    MacMenuBarPlatform.instance = MacMenuBarWebPlugin();
  }

  @override
  void setMenuItemSelectedHandler(MenuItemSelectedHandler handler) {}

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
  void setOnCopyFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnCutFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnPasteFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnSelectAllFromMenu(Future<bool> Function()? callback) {}
}
