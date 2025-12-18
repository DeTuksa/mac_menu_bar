import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  // Callback handlers for menu actions
  Future<bool> Function()? _onCut;
  Future<bool> Function()? _onCopy;
  Future<bool> Function()? _onPaste;
  Future<bool> Function()? _onSelectAll;

  /// Constructs a [MethodChannelMacMenuBar] and sets up the method call handler.
  ///
  /// This constructor initializes the method channel and sets up the handler
  /// for incoming method calls from the native platform.
  MethodChannelMacMenuBar() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles method calls from the native platform.
  ///
  /// This method is visible for testing purposes only. In production code,
  /// [_handleMethodCall] is used directly by the method channel.
  ///
  /// Returns a [Future] that completes with the result of handling the method call.
  /// The result will be `true` if the operation was handled, `false` otherwise.
  @visibleForTesting
  Future<dynamic> handleMethodCall(MethodCall call) {
    return _handleMethodCall(call);
  }

  /// Internal method to handle incoming method calls from the native platform.
  ///
  /// Routes the method call to the appropriate callback handler based on the
  /// method name. If no callback is registered for a method, returns `false`
  /// to indicate that the default system behavior should be used.
  ///
  /// Returns a [Future] that completes with `true` if the operation was handled,
  /// or `false` if no handler was registered for the method.
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
    }
    return false;
  }

  @override
  void setOnCopyFromMenu(Future<bool> Function()? callback) {
    _onCopy = callback;
  }

  @override
  void setOnCutFromMenu(Future<bool> Function()? callback) {
    _onCut = callback;
  }

  @override
  void setOnPasteFromMenu(Future<bool> Function()? callback) {
    _onPaste = callback;
  }

  @override
  void setOnSelectAllFromMenu(Future<bool> Function()? callback) {
    _onSelectAll = callback;
  }
}
