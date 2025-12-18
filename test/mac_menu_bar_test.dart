import 'package:flutter_test/flutter_test.dart';
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

  @override
  void setOnCutFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnCopyFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnPasteFromMenu(Future<bool> Function()? callback) {}

  @override
  void setOnSelectAllFromMenu(Future<bool> Function()? callback) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MacMenuBarPlatform initialPlatform = MacMenuBarPlatform.instance;

  test('$MethodChannelMacMenuBar is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMacMenuBar>());
  });
}
