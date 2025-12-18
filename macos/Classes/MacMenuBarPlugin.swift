import Cocoa
import FlutterMacOS

/// A Flutter plugin that provides access to macOS menu bar actions.
///
/// This plugin allows Flutter applications to handle standard menu bar actions
/// (Cut, Copy, Paste, Select All) on macOS by overriding the default menu item actions
/// and forwarding them to the Flutter application.
///
/// The plugin works by:
/// 1. Intercepting menu item actions from the main menu
/// 2. Sending method calls to the Flutter application
/// 3. Allowing the Flutter application to handle the action or fall back to the default behavior
public class MacMenuBarPlugin: NSObject, FlutterPlugin {
    
    /// The method channel used to communicate with the Flutter application.
    private var channel: FlutterMethodChannel!
    
    /// The original paste action selector before we overrode it.
    private var originalPasteAction: Selector?
    
    /// The original target for the paste action before we overrode it.
    private weak var originalPasteTarget: AnyObject?
    
    /// Represents an original menu item action that we've overridden.
    ///
    /// This is used to store the original target and selector of menu items
    /// so we can restore them if needed or forward actions to the original implementation.
    private struct OriginalAction {
        /// The original target object that handled the menu action
        let target: AnyObject?
        
        /// The original selector that was invoked for the menu action
        let selector: Selector
    }
    
    /// A dictionary that maps selectors to their original actions.
    ///
    /// This is used to store the original implementations of menu item actions
    /// so we can forward to them if the Flutter app doesn't handle the action.
    private var originalActions: [Selector: OriginalAction] = [:]
  /// Registers the plugin with the Flutter engine.
  ///
  /// This method is called by the Flutter engine when the plugin is first registered.
  /// It sets up the method channel and installs the menu item overrides.
  ///
  /// - Parameter registrar: The Flutter plugin registrar that provides access to the Flutter engine.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mac_menu_bar", binaryMessenger: registrar.messenger)
    let instance = MacMenuBarPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // Install menu overrides on the main thread
    DispatchQueue.main.async {
      instance.installMenuOverrides()
    }
  }

  /// Handles method calls from the Flutter application.
  ///
  /// This method is called when the Flutter application sends a method call to this plugin.
  /// Currently, this plugin doesn't handle any method calls from Flutter (only sends them),
  /// so this implementation is empty.
  ///
  /// - Parameters:
  ///   - call: The method call from Flutter.
  ///   - result: A closure to be called with the result of the method call.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // This plugin currently doesn't handle any method calls from Flutter
    // (it only sends method calls to Flutter), so we don't need to implement this.
    result(nil)
  }
    
    /// Finds a menu item in the main menu that matches the specified selector.
    ///
    /// This method searches through all items in the main menu and its submenus
    /// to find a menu item that has the specified action selector.
    ///
    /// - Parameter selector: The action selector to search for.
    /// - Returns: The first menu item that has the specified action, or `nil` if not found.
    private func findMenuItem(for selector: Selector) -> NSMenuItem? {
        guard let mainMenu = NSApplication.shared.mainMenu else { return nil }
        
        // Search through all top-level menu items
        for topItem in mainMenu.items {
            guard let submenu = topItem.submenu else { continue }
            
            // Search through all items in the submenu
            for item in submenu.items where item.action == selector {
                return item
            }
        }
        
        return nil
    }
    
    /// Overrides a menu item's action with a custom handler.
    ///
    /// This method finds a menu item with the specified selector, saves its original
    /// target and action, and then replaces them with the specified handler.
    ///
    /// - Parameters:
    ///   - selector: The selector of the menu item to override.
    ///   - handler: The new selector that should handle the menu item's action.
    private func overrideMenuItem(
        selector: Selector,
        handler: Selector
    ) {
        // Find the menu item with the specified selector
        guard let item = findMenuItem(for: selector) else { return }
        
        // Save the original target and selector so we can forward to it later if needed
        originalActions[selector] = OriginalAction(
            target: item.target as AnyObject?,
            selector: selector
        )
        
        // Replace the target and action with our own
        item.target = self
        item.action = handler
    }
    
    /// Installs overrides for standard menu items.
    ///
    /// This method sets up our custom handlers for the standard Cut, Copy, Paste,
    /// and Select All menu items. It's called automatically when the plugin is registered.
    private func installMenuOverrides() {
        // Override the Cut menu item
        overrideMenuItem(
            selector: #selector(NSText.cut(_:)),
            handler: #selector(handleCut(_:))
        )

        // Override the Copy menu item
        overrideMenuItem(
            selector: #selector(NSText.copy(_:)),
            handler: #selector(handleCopy(_:))
        )

        // Override the Paste menu item
        overrideMenuItem(
            selector: #selector(NSText.paste(_:)),
            handler: #selector(handlePaste(_:))
        )

        // Override the Select All menu item
        overrideMenuItem(
            selector: #selector(NSText.selectAll(_:)),
            handler: #selector(handleSelectAll(_:))
        )
    }
    
    /// Forwards an action to the original handler.
    ///
    /// This method is called when the Flutter app doesn't handle a menu action,
    /// allowing the default system behavior to take over.
    ///
    /// - Parameters:
    ///   - selector: The selector of the action to forward.
    ///   - sender: The sender of the action.
    private func forwardDefaultAction(
        _ selector: Selector,
        sender: Any?
    ) {
        guard let original = originalActions[selector] else { return }

        // Forward the action to the original target
        NSApp.sendAction(
            original.selector,
            to: original.target,
            from: sender
        )
    }
    
    /// Handles the Copy menu item action.
    ///
    /// This method is called when the user selects the Copy menu item.
    /// It sends a method call to the Flutter app and waits for a response.
    /// If the Flutter app doesn't handle the action (returns false or nil),
    /// it falls back to the default system behavior.
    ///
    /// - Parameter sender: The object that sent the action.
    @objc private func handleCopy(_ sender: Any?) {
        channel.invokeMethod("onCopyFromMenu", arguments: nil) { [weak self] handled in
            // If the Flutter app handled the action, we're done
            if let didHandle = handled as? Bool, didHandle {
                return
            }
            
            // Otherwise, forward to the default handler
            self?.forwardDefaultAction(#selector(NSText.copy(_:)), sender: sender)
        }
    }
    
    @objc func handleCut(_ sender: Any?) {
        channel.invokeMethod("onCutFromMenu", arguments: nil) { handled in
            if let didHandle = handled as? Bool, didHandle {
                return
            }
            self.forwardDefaultAction(#selector(NSText.cut(_:)), sender: sender)
        }
    }

    @objc func handlePaste(_ sender: Any?) {
        channel.invokeMethod("onPasteFromMenu", arguments: nil) { handled in
            if let didHandle = handled as? Bool, didHandle {
                return
            }
            self.forwardDefaultAction(#selector(NSText.paste(_:)), sender: sender)
        }
    }

    @objc func handleSelectAll(_ sender: Any?) {
        channel.invokeMethod("onSelectAllFromMenu", arguments: nil) { handled in
            if let didHandle = handled as? Bool, didHandle {
                return
            }
            self.forwardDefaultAction(#selector(NSText.selectAll(_:)), sender: sender)
        }
    }
}
