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

    /// A dictionary that maps custom menu item IDs to their selectors.
    private var customMenuItems: [String: Selector] = [:]
    
    /// Counter for generating unique selectors for custom menu items.
    private var menuItemCounter: Int = 0
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
    switch call.method {
        case "addMenuItem":
            handleAddMenuItem(call: call, result: result)
        case "addSubmenu":
            handleAddSubmenu(call: call, result: result)
        case "removeMenuItem":
            handleRemoveMenuItem(call: call, result: result)
        case "updateMenuItem":
            handleUpdateMenuItem(call: call, result: result)
        case "setMenuItemEnabled":
            handleSetMenuItemEnabled(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
  }

  /// Handles adding a menu item to the menu bar.
    private func handleAddMenuItem(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let menuId = args["menuId"] as? String,
              let itemId = args["itemId"] as? String,
              let title = args["title"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Missing required arguments", 
                              details: nil))
            return
        }
        
        let index = args["index"] as? Int
        let keyEquivalent = args["keyEquivalent"] as? String ?? ""
        let keyModifiers = args["keyModifiers"] as? [String] ?? []
        let enabled = args["enabled"] as? Bool ?? true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(false)
                return
            }
            
            let success = self.addMenuItem(
                menuId: menuId,
                itemId: itemId,
                title: title,
                index: index,
                keyEquivalent: keyEquivalent,
                keyModifiers: keyModifiers,
                enabled: enabled
            )
            result(success)
        }
    }
    
    /// Handles adding a submenu to the menu bar.
    private func handleAddSubmenu(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentMenuId = args["parentMenuId"] as? String,
              let submenuId = args["submenuId"] as? String,
              let title = args["title"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Missing required arguments", 
                              details: nil))
            return
        }
        
        let index = args["index"] as? Int
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(false)
                return
            }
            
            let success = self.addSubmenu(
                parentMenuId: parentMenuId,
                submenuId: submenuId,
                title: title,
                index: index
            )
            result(success)
        }
    }
    
    /// Handles removing a menu item.
    private func handleRemoveMenuItem(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let itemId = args["itemId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Missing itemId", 
                              details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(false)
                return
            }
            
            let success = self.removeMenuItem(itemId: itemId)
            result(success)
        }
    }
    
    /// Handles updating a menu item.
    private func handleUpdateMenuItem(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let itemId = args["itemId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Missing itemId", 
                              details: nil))
            return
        }
        
        let title = args["title"] as? String
        let enabled = args["enabled"] as? Bool
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(false)
                return
            }
            
            let success = self.updateMenuItem(
                itemId: itemId,
                title: title,
                enabled: enabled
            )
            result(success)
        }
    }
    
    /// Handles enabling/disabling a menu item.
    private func handleSetMenuItemEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let itemId = args["itemId"] as? String,
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Missing required arguments", 
                              details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(false)
                return
            }
            
            let success = self.setMenuItemEnabled(itemId: itemId, enabled: enabled)
            result(success)
        }
    }
    
    /// Adds a menu item to the specified menu.
    private func addMenuItem(
        menuId: String,
        itemId: String,
        title: String,
        index: Int?,
        keyEquivalent: String,
        keyModifiers: [String],
        enabled: Bool
    ) -> Bool {
        guard let menu = findMenu(byId: menuId) else {
            return false
        }
        
        // Create a unique selector for this menu item
        menuItemCounter += 1
        let selectorName = "handleCustomMenuItem\(menuItemCounter):"
        let selector = NSSelectorFromString(selectorName)
        
        // Store the mapping
        customMenuItems[itemId] = selector
        
        // Add the selector implementation dynamically
        let block: @convention(block) (Any?) -> Void = { [weak self] sender in
            self?.handleCustomMenuItemAction(itemId: itemId, sender: sender)
        }
        
        let imp = imp_implementationWithBlock(block)
        class_addMethod(type(of: self), selector, imp, "v@:@")
        
        // Create the menu item
        let menuItem = NSMenuItem(
            title: title,
            action: selector,
            keyEquivalent: keyEquivalent
        )
        menuItem.target = self
        menuItem.isEnabled = enabled
        menuItem.representedObject = itemId
        
        // Apply key modifiers
        menuItem.keyEquivalentModifierMask = parseKeyModifiers(keyModifiers)
        
        // Insert at the specified index or append
        if let index = index, index >= 0, index <= menu.items.count {
            menu.insertItem(menuItem, at: index)
        } else {
            menu.addItem(menuItem)
        }
        
        return true
    }
    
    /// Adds a submenu to the specified parent menu.
    private func addSubmenu(
        parentMenuId: String,
        submenuId: String,
        title: String,
        index: Int?
    ) -> Bool {
        guard let parentMenu = findMenu(byId: parentMenuId) else {
            return false
        }
        
        // Create the submenu
        let submenu = NSMenu(title: title)
        
        // Create the menu item that will hold the submenu
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.submenu = submenu
        menuItem.identifier = NSUserInterfaceItemIdentifier(submenuId)
        menuItem.representedObject = submenuId
        
        // Insert at the specified index or append
        if let index = index, index >= 0, index <= parentMenu.items.count {
            parentMenu.insertItem(menuItem, at: index)
        } else {
            parentMenu.addItem(menuItem)
        }
        
        return true
    }
    
    /// Removes a menu item by its ID.
    private func removeMenuItem(itemId: String) -> Bool {
        guard let mainMenu = NSApplication.shared.mainMenu else { return false }
        
        if let menuItem = findMenuItem(byId: itemId, in: mainMenu) {
            menuItem.menu?.removeItem(menuItem)
            customMenuItems.removeValue(forKey: itemId)
            return true
        }
        
        return false
    }
    
    /// Updates a menu item's properties.
    private func updateMenuItem(itemId: String, title: String?, enabled: Bool?) -> Bool {
        guard let mainMenu = NSApplication.shared.mainMenu,
              let menuItem = findMenuItem(byId: itemId, in: mainMenu) else {
            return false
        }
        
        if let title = title {
            menuItem.title = title
        }
        
        if let enabled = enabled {
            menuItem.isEnabled = enabled
        }
        
        return true
    }
    
    /// Sets a menu item's enabled state.
    private func setMenuItemEnabled(itemId: String, enabled: Bool) -> Bool {
        return updateMenuItem(itemId: itemId, title: nil, enabled: enabled)
    }
    
    /// Handles custom menu item actions.
    private func handleCustomMenuItemAction(itemId: String, sender: Any?) {
        channel.invokeMethod("onMenuItemSelected", arguments: ["itemId": itemId])
    }
    
    /// Finds a menu by its ID.
    private func findMenu(byId menuId: String) -> NSMenu? {
        guard let mainMenu = NSApplication.shared.mainMenu else { return nil }
        
        // Check if it's the main menu itself
        if menuId == "main" {
            return mainMenu
        }
        
        // Search through all menus recursively
        return findMenuRecursive(menuId: menuId, in: mainMenu)
    }
    
    /// Recursively searches for a menu by ID.
    private func findMenuRecursive(menuId: String, in menu: NSMenu) -> NSMenu? {
        // Check if this menu matches
        if menu.title == menuId {
            return menu
        }
        
        // Check all submenus
        for item in menu.items {
            if let submenu = item.submenu {
                if submenu.title == menuId || item.representedObject as? String == menuId {
                    return submenu
                }
                
                // Recursively search in submenu
                if let found = findMenuRecursive(menuId: menuId, in: submenu) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    /// Finds a menu item by its ID.
    private func findMenuItem(byId itemId: String, in menu: NSMenu) -> NSMenuItem? {
        for item in menu.items {
            if item.representedObject as? String == itemId {
                return item
            }
            
            if let submenu = item.submenu,
               let found = findMenuItem(byId: itemId, in: submenu) {
                return found
            }
        }
        
        return nil
    }
    
    /// Parses key modifiers from string array.
    private func parseKeyModifiers(_ modifiers: [String]) -> NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        
        for modifier in modifiers {
            switch modifier.lowercased() {
            case "command", "cmd":
                flags.insert(.command)
            case "shift":
                flags.insert(.shift)
            case "option", "alt":
                flags.insert(.option)
            case "control", "ctrl":
                flags.insert(.control)
            case "function", "fn":
                flags.insert(.function)
            default:
                break
            }
        }
        
        return flags
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
