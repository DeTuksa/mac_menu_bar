import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mac_menu_bar/mac_menu_bar_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelMacMenuBar platform;
  const MethodChannel channel = MethodChannel('mac_menu_bar');

  setUp(() {
    platform = MethodChannelMacMenuBar();
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

    final result = await platform
        .handleMethodCall(const MethodCall('onPasteFromMenu'));

    expect(called, isTrue);
    expect(result, isTrue);
  });

  test('onCopyFromMenu invokes Dart handler and returns false', () async {
    bool called = false;

    platform.setOnCopyFromMenu(() async {
      called = true;
      return false;
    });

    final result = await platform
        .handleMethodCall(const MethodCall('onCopyFromMenu'));

    expect(called, isTrue);
    expect(result, isFalse);
  });

  test('onCutFromMenu falls back when no handler registered', () async {
    final result =
    await platform.handleMethodCall(const MethodCall('onCutFromMenu'));

    expect(result, isFalse);
  });

  test('onSelectAllFromMenu falls back when handler returns null', () async {
    platform.setOnSelectAllFromMenu(() async => false);

    final result = await platform
        .handleMethodCall(const MethodCall('onSelectAllFromMenu'));

    expect(result, isFalse);
  });
}
