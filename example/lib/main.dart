import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:mac_menu_bar/mac_menu_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MacMenuBar.onPaste(() async {
      debugPrint('Paste menu item selected');
      return false;
    });
    MacMenuBar.onSelectAll(() async {
      debugPrint('Look at that');
      return false;
    });
    MacMenuBar.onCut(() async {
      debugPrint('Cut menu item selected');
      return false;
    });
    MacMenuBar.onCopy(() async {
      debugPrint('Copy menu item selected');
      return false;
    });
    _setupCustomMenus();
  }

  Future<void> _setupCustomMenus() async {
    // Add a custom submenu to the main menu bar
    await MacMenuBar.addSubmenu(
      parentMenuId: 'main',
      submenuId: 'custom_menu',
      title: 'Custom',
      index: 3,
    );

    await MacMenuBar.addMenuItem(
      menuId: 'View',
      itemId: 'refresh',
      title: 'Refresh',
    );

    // Add menu items to the custom submenu with keyboard shortcuts
    await MacMenuBar.addMenuItem(
      menuId: 'custom_menu',
      itemId: 'new_document',
      title: 'New Document',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.keyN,
        meta: true,
        shift: true,
      ), // Cmd+Shift+N
    );

    await MacMenuBar.addMenuItem(
      menuId: 'custom_menu',
      itemId: 'open_preferences',
      title: 'Preferences...',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.comma,
        meta: true,
      ), // Cmd+,
    );

    // Add a separator (disabled item with special title)
    await MacMenuBar.addMenuItem(
      menuId: 'custom_menu',
      itemId: 'separator_1',
      title: '-',
      enabled: false,
    );

    // Add a submenu within the custom menu
    await MacMenuBar.addSubmenu(
      parentMenuId: 'custom_menu',
      submenuId: 'tools',
      title: 'Tools',
    );

    await MacMenuBar.addMenuItem(
      menuId: 'tools',
      itemId: 'tool_1',
      title: 'Tool 1',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.digit1,
        meta: true,
        alt: true,
      ), // Cmd+Option+1
    );

    await MacMenuBar.addMenuItem(
      menuId: 'tools',
      itemId: 'tool_2',
      title: 'Tool 2',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.digit2,
        meta: true,
        alt: true,
      ), // Cmd+Option+2
    );

    // Add a nested submenu for complex menu structures
    await MacMenuBar.addSubmenu(
      parentMenuId: 'tools',
      submenuId: 'advanced_tools',
      title: 'Advanced',
    );

    await MacMenuBar.addMenuItem(
      menuId: 'advanced_tools',
      itemId: 'advanced_tool_1',
      title: 'Advanced Tool 1',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.f1,
        meta: true,
      ), // Cmd+F1
    );

    // Add items to the File menu
    await MacMenuBar.addMenuItem(
      menuId: 'File',
      itemId: 'export',
      title: 'Export...',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.keyE,
        meta: true,
        shift: true,
      ), // Cmd+Shift+E
    );

    await MacMenuBar.addMenuItem(
      menuId: 'File',
      itemId: 'recent',
      title: 'Open Recent',
      shortcut: const SingleActivator(
        LogicalKeyboardKey.keyR,
        meta: true,
        shift: true,
      ), // Cmd+Shift+R
    );

    // Set up handler for custom menu item selections
    MacMenuBar.setMenuItemSelectedHandler((itemId) {
      // Handle custom menu items
      _handleCustomMenuItem(itemId);
    });
  }

  void _handleCustomMenuItem(String itemId) {
    switch (itemId) {
      case 'new_document':
        debugPrint('Creating new document...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creating new document... (Cmd+Shift+N)'),
          ),
        );
        break;
      case 'open_preferences':
        debugPrint('Opening preferences...');
        break;
      case 'export':
        debugPrint('Exporting...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting... (Cmd+Shift+E)')),
        );
        break;
      case 'recent':
        debugPrint('Opening recent files...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening recent files... (Cmd+Shift+R)'),
          ),
        );
        break;
      case 'tool_1':
        debugPrint('Running Tool 1...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Running Tool 1... (Cmd+Option+1)')),
        );
        break;
      case 'tool_2':
        debugPrint('Running Tool 2...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Running Tool 2... (Cmd+Option+2)')),
        );
        break;
      case 'advanced_tool_1':
        debugPrint('Running Advanced Tool 1...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Running Advanced Tool 1... (Cmd+F1)')),
        );
        break;
      default:
        debugPrint('Unknown menu item: $itemId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: TextField()),
      ),
    );
  }
}
