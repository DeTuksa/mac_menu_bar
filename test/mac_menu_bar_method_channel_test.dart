import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mac_menu_bar/mac_menu_bar_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelMacMenuBar platform;
  const MethodChannel channel = MethodChannel('mac_menu_bar');
  final List<MethodCall> methodCallLog = [];

  setUp(() {
    platform = MethodChannelMacMenuBar();
    methodCallLog.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
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
        .setMockMethodCallHandler(channel, null);
  });

  test('onPasteFromMenu invokes Dart handler and returns true', () async {
    bool called = false;

    platform.setOnPasteFromMenu(() async {
      called = true;
      return true;
    });

    final result = await platform.handleMethodCall(
      const MethodCall('onPasteFromMenu'),
    );

    expect(called, isTrue);
    expect(result, isTrue);
  });

  test('onCopyFromMenu invokes Dart handler and returns false', () async {
    bool called = false;

    platform.setOnCopyFromMenu(() async {
      called = true;
      return false;
    });

    final result = await platform.handleMethodCall(
      const MethodCall('onCopyFromMenu'),
    );

    expect(called, isTrue);
    expect(result, isFalse);
  });

  test('onCutFromMenu falls back when no handler registered', () async {
    final result = await platform.handleMethodCall(
      const MethodCall('onCutFromMenu'),
    );

    expect(result, isFalse);
  });

  test('onSelectAllFromMenu falls back when handler returns null', () async {
    platform.setOnSelectAllFromMenu(() async => false);

    final result = await platform.handleMethodCall(
      const MethodCall('onSelectAllFromMenu'),
    );

    expect(result, isFalse);
  });

  group('Menu Item Selection Handler', () {
    test('onMenuItemSelected invokes Dart handler with itemId', () async {
      String? receivedItemId;

      platform.setMenuItemSelectedHandler((itemId) {
        receivedItemId = itemId;
      });

      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', {'itemId': 'test_item'}),
      );

      expect(receivedItemId, 'test_item');
    });

    test('handles multiple item selections', () async {
      final List<String> selectedItems = [];

      platform.setMenuItemSelectedHandler((itemId) {
        selectedItems.add(itemId);
      });

      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', {'itemId': 'item1'}),
      );
      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', {'itemId': 'item2'}),
      );
      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', {'itemId': 'item3'}),
      );

      expect(selectedItems, ['item1', 'item2', 'item3']);
    });

    test('does nothing when no handler registered', () async {
      // Should not throw
      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', {'itemId': 'test'}),
      );
    });

    test('handles invalid arguments gracefully', () async {
      String? receivedItemId;

      platform.setMenuItemSelectedHandler((itemId) {
        receivedItemId = itemId;
      });

      // Missing itemId in arguments
      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', {}),
      );

      expect(receivedItemId, isNull);
    });

    test('handles non-map arguments gracefully', () async {
      String? receivedItemId;

      platform.setMenuItemSelectedHandler((itemId) {
        receivedItemId = itemId;
      });

      // Non-map argument
      await platform.handleMethodCall(
        const MethodCall('onMenuItemSelected', 'invalid'),
      );

      expect(receivedItemId, isNull);
    });
  });

  group('Platform Method Calls', () {
    test('addMenuItem sends correct data', () async {
      await platform.addMenuItem(
        menuId: 'File',
        itemId: 'new_file',
        title: 'New File',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
      );

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'addMenuItem');
      expect(methodCallLog[0].arguments['menuId'], 'File');
      expect(methodCallLog[0].arguments['itemId'], 'new_file');
      expect(methodCallLog[0].arguments['title'], 'New File');
      expect(methodCallLog[0].arguments['keyEquivalent'], 'n');
      expect(methodCallLog[0].arguments['keyModifiers'], ['command']);
      expect(methodCallLog[0].arguments['enabled'], true);
    });

    test('addMenuItem without shortcut sends empty key data', () async {
      await platform.addMenuItem(
        menuId: 'Edit',
        itemId: 'item1',
        title: 'Item 1',
      );

      expect(methodCallLog[0].arguments['keyEquivalent'], '');
      expect(methodCallLog[0].arguments['keyModifiers'], isEmpty);
    });

    test('addMenuItem with index sends index', () async {
      await platform.addMenuItem(
        menuId: 'View',
        itemId: 'item2',
        title: 'Item 2',
        index: 3,
      );

      expect(methodCallLog[0].arguments['index'], 3);
    });

    test('addMenuItem with disabled state', () async {
      await platform.addMenuItem(
        menuId: 'Window',
        itemId: 'item3',
        title: 'Item 3',
        enabled: false,
      );

      expect(methodCallLog[0].arguments['enabled'], false);
    });

    test('addSubmenu sends correct data', () async {
      await platform.addSubmenu(
        parentMenuId: 'main',
        submenuId: 'custom_menu',
        title: 'Custom',
      );

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'addSubmenu');
      expect(methodCallLog[0].arguments['parentMenuId'], 'main');
      expect(methodCallLog[0].arguments['submenuId'], 'custom_menu');
      expect(methodCallLog[0].arguments['title'], 'Custom');
    });

    test('addSubmenu with index', () async {
      await platform.addSubmenu(
        parentMenuId: 'File',
        submenuId: 'tools',
        title: 'Tools',
        index: 5,
      );

      expect(methodCallLog[0].arguments['index'], 5);
    });

    test('removeMenuItem sends correct data', () async {
      await platform.removeMenuItem('item_to_remove');

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'removeMenuItem');
      expect(methodCallLog[0].arguments['itemId'], 'item_to_remove');
    });

    test('updateMenuItem sends title update', () async {
      await platform.updateMenuItem(itemId: 'test_item', title: 'New Title');

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'updateMenuItem');
      expect(methodCallLog[0].arguments['itemId'], 'test_item');
      expect(methodCallLog[0].arguments['title'], 'New Title');
      expect(methodCallLog[0].arguments.containsKey('enabled'), false);
    });

    test('updateMenuItem sends enabled update', () async {
      await platform.updateMenuItem(itemId: 'test_item', enabled: false);

      expect(methodCallLog[0].arguments['enabled'], false);
      expect(methodCallLog[0].arguments.containsKey('title'), false);
    });

    test('updateMenuItem sends both updates', () async {
      await platform.updateMenuItem(
        itemId: 'test_item',
        title: 'Updated',
        enabled: true,
      );

      expect(methodCallLog[0].arguments['title'], 'Updated');
      expect(methodCallLog[0].arguments['enabled'], true);
    });

    test('setMenuItemEnabled sends correct data', () async {
      await platform.setMenuItemEnabled('my_item', false);

      expect(methodCallLog.length, 1);
      expect(methodCallLog[0].method, 'setMenuItemEnabled');
      expect(methodCallLog[0].arguments['itemId'], 'my_item');
      expect(methodCallLog[0].arguments['enabled'], false);
    });
  });

  group('Error Handling', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR', message: 'Test error');
          });
    });

    test('addMenuItem returns false on error', () async {
      final result = await platform.addMenuItem(
        menuId: 'File',
        itemId: 'test',
        title: 'Test',
      );

      expect(result, false);
    });

    test('addSubmenu returns false on error', () async {
      final result = await platform.addSubmenu(
        parentMenuId: 'main',
        submenuId: 'test',
        title: 'Test',
      );

      expect(result, false);
    });

    test('removeMenuItem returns false on error', () async {
      final result = await platform.removeMenuItem('test');

      expect(result, false);
    });

    test('updateMenuItem returns false on error', () async {
      final result = await platform.updateMenuItem(
        itemId: 'test',
        title: 'Test',
      );

      expect(result, false);
    });

    test('setMenuItemEnabled returns false on error', () async {
      final result = await platform.setMenuItemEnabled('test', true);

      expect(result, false);
    });
  });

  group('Unimplemented Methods', () {
    test('throws for unimplemented methods', () async {
      expect(
        () => platform.handleMethodCall(const MethodCall('unknownMethod')),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
