import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mac_menu_bar/mac_menu_bar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('menu callbacks can be registered without crashing',
          (WidgetTester tester) async {
        if (!Platform.isMacOS) {
          return;
        }

        bool pasteCalled = false;
        bool copyCalled = false;
        bool cutCalled = false;
        bool selectAllCalled = false;

        MacMenuBar.onPaste(() async {
          pasteCalled = true;
          return true;
        });

        MacMenuBar.onCopy(() async {
          copyCalled = true;
          return true;
        });

        MacMenuBar.onCut(() async {
          cutCalled = true;
          return true;
        });

        MacMenuBar.onSelectAll(() async {
          selectAllCalled = true;
          return true;
        });

        await tester.pumpAndSettle();

        expect(pasteCalled, isFalse);
        expect(copyCalled, isFalse);
        expect(cutCalled, isFalse);
        expect(selectAllCalled, isFalse);
      });
}
