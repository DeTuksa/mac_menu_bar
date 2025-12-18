import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mac_menu_bar_method_channel.dart';

/// The interface that implementations of `mac_menu_bar` must implement.
///
/// Platform-specific implementations should extend this class instead of directly
/// extending [PlatformInterface] to ensure they are using the correct platform
/// interface for functionality that depends on the platform's implementation.
abstract class MacMenuBarPlatform extends PlatformInterface {
  /// Constructs a MacMenuBarPlatform.
  MacMenuBarPlatform() : super(token: _token);

  /// The token used to verify that platform implementations extend this class
  static final Object _token = Object();

  /// The default instance of [MacMenuBarPlatform] to use.
  ///
  /// Defaults to [MethodChannelMacMenuBar] which uses method channels for
  /// communication with the native platform.
  static MacMenuBarPlatform _instance = MethodChannelMacMenuBar();

  /// Returns the current platform instance.
  ///
  /// This getter returns the current platform implementation, which defaults to
  /// [MethodChannelMacMenuBar].
  static MacMenuBarPlatform get instance => _instance;

  /// Sets the platform instance that will be used by the plugin.
  ///
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MacMenuBarPlatform] when
  /// they register themselves.
  ///
  /// Throws an [AssertionError] if the provided instance does not extend
  /// [MacMenuBarPlatform].
  static set instance(MacMenuBarPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sets the callback that will be invoked when the Cut menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnCutFromMenu(Future<bool> Function()? callback);

  /// Sets the callback that will be invoked when the Copy menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnCopyFromMenu(Future<bool> Function()? callback);

  /// Sets the callback that will be invoked when the Paste menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnPasteFromMenu(Future<bool> Function()? callback);

  /// Sets the callback that will be invoked when the Select All menu item is selected.
  ///
  /// The callback should return a [Future] that completes with `true` if the
  /// operation was handled, or `false` to allow the default system behavior.
  ///
  /// Set to `null` to restore the default system behavior.
  void setOnSelectAllFromMenu(Future<bool> Function()? callback);
}
