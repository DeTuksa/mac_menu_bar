import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show SingleActivator;

import 'mac_menu_bar_platform_interface.dart';

/// The method channel implementation of [MacMenuBarPlatform].
///
/// This class implements the platform interface using platform channels to
/// communicate with the native platform code. It handles the method channel
/// communication and manages the callbacks for menu actions.
///
/// This class should not be instantiated directly. Instead, access it through
/// [MacMenuBarPlatform.instance].
class MethodChannelMacMenuBar extends MacMenuBarPlatform {
  /// The method channel used to communicate with the native platform.
  ///
  /// This channel is used to receive menu action events from the native side
  /// and forward them to the appropriate callbacks.
  @visibleForTesting
  final methodChannel = const MethodChannel('mac_menu_bar');

  /// Whether the current platform is macOS.
  ///
  /// This is used to determine whether to attempt platform channel communication
  /// or use no-op behavior.
  final bool _isMacOS;

  /// Handler for custom menu item selections.
  ///
  /// This callback is invoked when a custom menu item is selected by the user.
  /// It receives the ID of the selected menu item as a parameter.
  MenuItemSelectedHandler? _menuItemSelectedHandler;

  /// Callback for handling the Cut menu action.
  ///
  /// This is called when the user selects the Cut menu item or uses the
  /// system keyboard shortcut (Cmd+X).
  Future<bool> Function()? _onCut;

  /// Callback for handling the Copy menu action.
  ///
  /// This is called when the user selects the Copy menu item or uses the
  /// system keyboard shortcut (Cmd+C).
  Future<bool> Function()? _onCopy;

  /// Callback for handling the Paste menu action.
  ///
  /// This is called when the user selects the Paste menu item or uses the
  /// system keyboard shortcut (Cmd+V).
  Future<bool> Function()? _onPaste;

  /// Callback for handling the Select All menu action.
  ///
  /// This is called when the user selects the Select All menu item or uses the
  /// system keyboard shortcut (Cmd+A).
  Future<bool> Function()? _onSelectAll;

  /// Constructs a [MethodChannelMacMenuBar] and sets up the method call handler.
  ///
  /// This constructor initializes the method channel and sets up the handler
  /// for incoming method calls from the native platform.
  MethodChannelMacMenuBar()
    : _isMacOS = defaultTargetPlatform == TargetPlatform.macOS {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles method calls from the native platform.
  ///
  /// This method processes incoming method calls from the native platform and routes them
  /// to the appropriate handler methods. It's the main entry point for all platform channel
  /// communication in this plugin.
  ///
  /// This method is visible for testing purposes only. In production code,
  /// [_handleMethodCall] is used directly by the method channel.
  ///
  /// ## Parameters:
  ///   - `call`: The [MethodCall] object containing the method name and arguments.
  ///
  /// ## Returns:
  /// A [Future] that completes with the result of handling the method call.
  /// The result will be `true` if the operation was handled successfully,
  /// `false` otherwise.
  ///
  /// ## Throws:
  ///   - [PlatformException] if the method call is not recognized or if there's
  ///     an error processing the request.
  @visibleForTesting
  Future<dynamic> handleMethodCall(MethodCall call) {
    return _handleMethodCall(call);
  }

  /// Internal method to handle incoming method calls from the native platform.
  ///
  /// This method is the main entry point for all platform channel communication.
  /// It routes incoming method calls to their respective handlers based on the
  /// method name.
  ///
  /// ## Parameters:
  ///   - `call`: The [MethodCall] object containing the method name and arguments.
  ///
  /// ## Returns:
  /// A [Future] that completes with `true` if the method was handled,
  /// `false` if no handler was found, or throws a [PlatformException] for
  /// unimplemented methods.
  ///
  /// ## Throws:
  ///   - [PlatformException] if the method is not implemented.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCutFromMenu':
        return await _onCut?.call() ?? false;
      case 'onCopyFromMenu':
        return await _onCopy?.call() ?? false;
      case 'onPasteFromMenu':
        return await _onPaste?.call() ?? false;
      case 'onSelectAllFromMenu':
        return await _onSelectAll?.call() ?? false;
      case 'onMenuItemSelected':
        _handleMenuItemSelected(call.arguments);
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
    return false;
  }

  /// Handles the selection of a custom menu item.
  ///
  /// This method is called when a custom menu item is selected by the user.
  /// It extracts the menu item ID from the arguments and invokes the registered
  /// callback if one exists.
  ///
  /// ## Parameters:
  ///   - `arguments`: The arguments received from the platform channel.
  ///     Expected to be a [Map] containing at least an 'itemId' key.
  void _handleMenuItemSelected(dynamic arguments) {
    if (_menuItemSelectedHandler == null) {
      return;
    }

    if (arguments is Map) {
      final itemId = arguments['itemId'] as String?;
      if (itemId != null) {
        _menuItemSelectedHandler!(itemId);
      }
    }
  }

  /// Sets the callback to be invoked when the Copy menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// ## Parameters:
  ///   - `callback`: The callback to invoke, or `null` to clear the handler.
  @override
  void setOnCopyFromMenu(Future<bool> Function()? callback) {
    _onCopy = callback;
  }

  /// Sets the callback to be invoked when the Cut menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// ## Parameters:
  ///   - `callback`: The callback to invoke, or `null` to clear the handler.
  @override
  void setOnCutFromMenu(Future<bool> Function()? callback) {
    _onCut = callback;
  }

  /// Sets the callback to be invoked when the Paste menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// ## Parameters:
  ///   - `callback`: The callback to invoke, or `null` to clear the handler.
  @override
  void setOnPasteFromMenu(Future<bool> Function()? callback) {
    _onPaste = callback;
  }

  /// Sets the callback to be invoked when the Select All menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// ## Parameters:
  ///   - `callback`: The callback to invoke, or `null` to clear the handler.
  @override
  void setOnSelectAllFromMenu(Future<bool> Function()? callback) {
    _onSelectAll = callback;
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
    if (!_isMacOS && kReleaseMode) return false;

    try {
      final args = <String, dynamic>{
        'menuId': menuId,
        'itemId': itemId,
        'title': title,
        if (index != null) 'index': index,
        'enabled': enabled,
      };

      // Add shortcut data if provided
      if (shortcut != null) {
        final shortcutData = shortcut.toMap();
        args['keyEquivalent'] = shortcutData['keyEquivalent'];
        args['keyModifiers'] = shortcutData['keyModifiers'];
      } else {
        args['keyEquivalent'] = '';
        args['keyModifiers'] = <String>[];
      }

      final result = await methodChannel.invokeMethod<bool>(
        'addMenuItem',
        args,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error adding menu item: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> addSubmenu({
    required String parentMenuId,
    required String submenuId,
    required String title,
    int? index,
  }) async {
    if (!_isMacOS && kReleaseMode) return false;

    try {
      final result = await methodChannel
          .invokeMethod<bool>('addSubmenu', <String, dynamic>{
            'parentMenuId': parentMenuId,
            'submenuId': submenuId,
            'title': title,
            if (index != null) 'index': index,
          });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error adding submenu: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> removeMenuItem(String itemId) async {
    if (!_isMacOS && kReleaseMode) return false;

    try {
      final result = await methodChannel.invokeMethod<bool>(
        'removeMenuItem',
        <String, dynamic>{'itemId': itemId},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error removing menu item: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setMenuItemEnabled(String itemId, bool enabled) async {
    if (!_isMacOS && kReleaseMode) return false;

    try {
      final result = await methodChannel.invokeMethod<bool>(
        'setMenuItemEnabled',
        <String, dynamic>{'itemId': itemId, 'enabled': enabled},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error setting menu item enabled state: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> updateMenuItem({
    required String itemId,
    String? title,
    bool? enabled,
  }) async {
    if (!_isMacOS && kReleaseMode) return false;

    try {
      final result = await methodChannel
          .invokeMethod<bool>('updateMenuItem', <String, dynamic>{
            'itemId': itemId,
            if (title != null) 'title': title,
            if (enabled != null) 'enabled': enabled,
          });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error updating menu item: ${e.message}');
      return false;
    }
  }

  @override
  void setMenuItemSelectedHandler(MenuItemSelectedHandler handler) {
    _menuItemSelectedHandler = handler;
  }
}
