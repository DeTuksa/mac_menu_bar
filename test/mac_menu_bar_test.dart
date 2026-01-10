import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/shortcuts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mac_menu_bar/mac_menu_bar.dart';
import 'package:mac_menu_bar/mac_menu_bar_platform_interface.dart';
import 'package:mac_menu_bar/mac_menu_bar_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMacMenuBarPlatform
    with MockPlatformInterfaceMixin
    implements MacMenuBarPlatform {
  bool cutCalled = false;
  bool copyCalled = false;
  bool pasteCalled = false;
  bool selectAllCalled = false;

  MenuItemSelectedHandler? _menuItemSelectedHandler;

  final List<Map<String, dynamic>> addedMenuItems = [];
  final List<Map<String, dynamic>> addedSubmenus = [];
  final List<String> removedMenuItems = [];
  final List<Map<String, dynamic>> updatedMenuItems = [];

  @override
  void setOnCutFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnCopyFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnPasteFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnSelectAllFromMenu(Future<bool> Function()? callback) {}

  @override
  void setMenuItemSelectedHandler(MenuItemSelectedHandler handler) {
    _menuItemSelectedHandler = handler;
  }

  @override
  Future<bool> addMenuItem({
    required String menuId,
    required String itemId,
    required String title,
    int? index,
    SingleActivator? shortcut,
    bool enabled = true,
  }) async {
    addedMenuItems.add({
      'menuId': menuId,
      'itemId': itemId,
      'title': title,
      'index': index,
      'shortcut': shortcut,
      'enabled': enabled,
    });
    return true;
  }

  @override
  Future<bool> addSubmenu({
    required String parentMenuId,
    required String submenuId,
    required String title,
    int? index,
  }) async {
    addedSubmenus.add({
      'parentMenuId': parentMenuId,
      'submenuId': submenuId,
      'title': title,
      'index': index,
    });
    return true;
  }

  @override
  Future<bool> removeMenuItem(String itemId) async {
    removedMenuItems.add(itemId);
    return true;
  }

  @override
  Future<bool> updateMenuItem({
    required String itemId,
    String? title,
    bool? enabled,
  }) async {
    updatedMenuItems.add({
      'itemId': itemId,
      'title': title,
      'enabled': enabled,
    });
    return true;
  }

  @override
  Future<bool> setMenuItemEnabled(String itemId, bool enabled) async {
    updatedMenuItems.add({'itemId': itemId, 'enabled': enabled});
    return true;
  }

  void simulateMenuItemSelected(String itemId) {
    _menuItemSelectedHandler?.call(itemId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MacMenuBarPlatform initialPlatform = MacMenuBarPlatform.instance;

  test('$MethodChannelMacMenuBar is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMacMenuBar>());
  });

  group('MacMenuBarPlatform', () {
    final MacMenuBarPlatform initialPlatform = MacMenuBarPlatform.instance;

    test('$MethodChannelMacMenuBar is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelMacMenuBar>());
    });

    test('Can set a mock platform instance', () {
      final mockPlatform = MockMacMenuBarPlatform();
      MacMenuBarPlatform.instance = mockPlatform;
      expect(MacMenuBarPlatform.instance, mockPlatform);

      // Reset to original
      MacMenuBarPlatform.instance = initialPlatform;
    });
  });

  group('MacMenuBar API', () {
    late MockMacMenuBarPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockMacMenuBarPlatform();
      MacMenuBarPlatform.instance = mockPlatform;
    });

    tearDown(() {
      MacMenuBarPlatform.instance = MethodChannelMacMenuBar();
    });

    test('setMenuItemSelectedHandler registers handler', () {
      String? selectedItemId;

      MacMenuBar.setMenuItemSelectedHandler((itemId) {
        selectedItemId = itemId;
      });

      mockPlatform.simulateMenuItemSelected('test_item');

      expect(selectedItemId, 'test_item');
    });

    test('addMenuItem without shortcut', () async {
      final result = await MacMenuBar.addMenuItem(
        menuId: 'File',
        itemId: 'test_item',
        title: 'Test Item',
      );

      expect(result, true);
      expect(mockPlatform.addedMenuItems.length, 1);
      expect(mockPlatform.addedMenuItems[0]['menuId'], 'File');
      expect(mockPlatform.addedMenuItems[0]['itemId'], 'test_item');
      expect(mockPlatform.addedMenuItems[0]['title'], 'Test Item');
      expect(mockPlatform.addedMenuItems[0]['shortcut'], null);
      expect(mockPlatform.addedMenuItems[0]['enabled'], true);
    });

    test('addMenuItem with SingleActivator shortcut', () async {
      const shortcut = SingleActivator(
        LogicalKeyboardKey.keyN,
        meta: true,
        shift: true,
      );

      final result = await MacMenuBar.addMenuItem(
        menuId: 'File',
        itemId: 'new_item',
        title: 'New Item',
        shortcut: shortcut,
      );

      expect(result, true);
      expect(mockPlatform.addedMenuItems.length, 1);
      expect(mockPlatform.addedMenuItems[0]['shortcut'], shortcut);
    });

    test('addMenuItem with index and disabled state', () async {
      final result = await MacMenuBar.addMenuItem(
        menuId: 'Edit',
        itemId: 'disabled_item',
        title: 'Disabled Item',
        index: 2,
        enabled: false,
      );

      expect(result, true);
      expect(mockPlatform.addedMenuItems[0]['index'], 2);
      expect(mockPlatform.addedMenuItems[0]['enabled'], false);
    });

    test('addSubmenu creates submenu', () async {
      final result = await MacMenuBar.addSubmenu(
        parentMenuId: 'main',
        submenuId: 'custom_menu',
        title: 'Custom',
      );

      expect(result, true);
      expect(mockPlatform.addedSubmenus.length, 1);
      expect(mockPlatform.addedSubmenus[0]['parentMenuId'], 'main');
      expect(mockPlatform.addedSubmenus[0]['submenuId'], 'custom_menu');
      expect(mockPlatform.addedSubmenus[0]['title'], 'Custom');
    });

    test('addSubmenu with index', () async {
      final result = await MacMenuBar.addSubmenu(
        parentMenuId: 'File',
        submenuId: 'tools',
        title: 'Tools',
        index: 5,
      );

      expect(result, true);
      expect(mockPlatform.addedSubmenus[0]['index'], 5);
    });

    test('removeMenuItem removes item', () async {
      final result = await MacMenuBar.removeMenuItem('test_item');

      expect(result, true);
      expect(mockPlatform.removedMenuItems.length, 1);
      expect(mockPlatform.removedMenuItems[0], 'test_item');
    });

    test('updateMenuItem updates title', () async {
      final result = await MacMenuBar.updateMenuItem(
        itemId: 'test_item',
        title: 'Updated Title',
      );

      expect(result, true);
      expect(mockPlatform.updatedMenuItems.length, 1);
      expect(mockPlatform.updatedMenuItems[0]['itemId'], 'test_item');
      expect(mockPlatform.updatedMenuItems[0]['title'], 'Updated Title');
      expect(mockPlatform.updatedMenuItems[0]['enabled'], null);
    });

    test('updateMenuItem updates enabled state', () async {
      final result = await MacMenuBar.updateMenuItem(
        itemId: 'test_item',
        enabled: false,
      );

      expect(result, true);
      expect(mockPlatform.updatedMenuItems[0]['enabled'], false);
      expect(mockPlatform.updatedMenuItems[0]['title'], null);
    });

    test('setMenuItemEnabled updates enabled state', () async {
      final result = await MacMenuBar.setMenuItemEnabled('test_item', false);

      expect(result, true);
      expect(mockPlatform.updatedMenuItems.length, 1);
      expect(mockPlatform.updatedMenuItems[0]['itemId'], 'test_item');
      expect(mockPlatform.updatedMenuItems[0]['enabled'], false);
    });
  });

  group('SingleActivatorExtension', () {
    test('toMap converts simple shortcut correctly', () {
      const activator = SingleActivator(LogicalKeyboardKey.keyN, meta: true);

      final map = activator.toMap();

      expect(map['keyEquivalent'], 'n');
      expect(map['keyModifiers'], ['command']);
    });

    test('toMap converts complex shortcut correctly', () {
      const activator = SingleActivator(
        LogicalKeyboardKey.keyS,
        meta: true,
        shift: true,
        alt: true,
        control: true,
      );

      final map = activator.toMap();

      expect(map['keyEquivalent'], 's');
      expect(map['keyModifiers'], contains('command'));
      expect(map['keyModifiers'], contains('shift'));
      expect(map['keyModifiers'], contains('option'));
      expect(map['keyModifiers'], contains('control'));
    });

    test('toMap converts comma shortcut correctly', () {
      const activator = SingleActivator(LogicalKeyboardKey.comma, meta: true);

      final map = activator.toMap();

      expect(map['keyEquivalent'], ',');
      expect(map['keyModifiers'], ['command']);
    });

    test('toMap converts number key correctly', () {
      const activator = SingleActivator(
        LogicalKeyboardKey.digit1,
        meta: true,
        alt: true,
      );

      final map = activator.toMap();

      expect(map['keyEquivalent'], '1');
      expect(map['keyModifiers'], contains('command'));
      expect(map['keyModifiers'], contains('option'));
    });

    test('toMap converts function key correctly', () {
      const activator = SingleActivator(LogicalKeyboardKey.f1, meta: true);

      final map = activator.toMap();

      expect(map['keyEquivalent'], '\u{F704}');
      expect(map['keyModifiers'], ['command']);
    });

    test('toMap converts special keys correctly', () {
      const deleteActivator = SingleActivator(
        LogicalKeyboardKey.delete,
        meta: true,
      );

      final deleteMap = deleteActivator.toMap();
      expect(deleteMap['keyEquivalent'], '\u{0008}');

      const escapeActivator = SingleActivator(LogicalKeyboardKey.escape);

      final escapeMap = escapeActivator.toMap();
      expect(escapeMap['keyEquivalent'], '\u{001B}');
    });

    test('toMap handles no modifiers', () {
      const activator = SingleActivator(LogicalKeyboardKey.keyA);

      final map = activator.toMap();

      expect(map['keyEquivalent'], 'a');
      expect(map['keyModifiers'], isEmpty);
    });
  });

  group('MethodChannelMacMenuBar', () {
    late MethodChannelMacMenuBar platform;
    final List<MethodCall> methodCallLog = [];

    setUp(() {
      platform = MethodChannelMacMenuBar();
      methodCallLog.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform.methodChannel, (
            MethodCall methodCall,
          ) async {
            methodCallLog.add(methodCall);

            switch (methodCall.method) {
              case 'addMenuItem':
              case 'addSubmenu':
              case 'removeMenuItem':
              case 'updateMenuItem':
              case 'setMenuItemEnabled':
                return true;
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform.methodChannel, null);
    });

    test('addMenuItem sends correct method call', () async {
      await platform.addMenuItem(
        menuId: 'File',
        itemId: 'test',
        title: 'Test',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyT, meta: true),
      );

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'addMenuItem');
      expect(methodCallLog[0].arguments['menuId'], 'File');
      expect(methodCallLog[0].arguments['itemId'], 'test');
      expect(methodCallLog[0].arguments['title'], 'Test');
      expect(methodCallLog[0].arguments['keyEquivalent'], 't');
      expect(methodCallLog[0].arguments['keyModifiers'], ['command']);
    });

    test('addSubmenu sends correct method call', () async {
      await platform.addSubmenu(
        parentMenuId: 'main',
        submenuId: 'custom',
        title: 'Custom',
      );

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'addSubmenu');
      expect(methodCallLog[0].arguments['parentMenuId'], 'main');
      expect(methodCallLog[0].arguments['submenuId'], 'custom');
      expect(methodCallLog[0].arguments['title'], 'Custom');
    });

    test('handles menu item selection callbacks', () async {
      String? selectedItemId;

      platform.setMenuItemSelectedHandler((itemId) {
        selectedItemId = itemId;
      });

      // Simulate incoming method call from native
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'mac_menu_bar',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('onMenuItemSelected', {'itemId': 'test_item'}),
            ),
            (ByteData? data) {},
          );

      expect(selectedItemId, 'test_item');
    });
  });
}
