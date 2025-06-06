//
//  AppDelegate.swift
//  Nay8UI
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Cocoa
import Contacts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var sender: Nay8
    var pluginManager: PluginManager
    var server: Nay8WebServer
    var databaseHelper: DatabaseHandler!
    override init() {
        UserDefaults.standard.register(defaults: [
            Nay8Constants.nay8IsDisabled: false,
            Nay8Constants.restApiIsDisabled: true,
            Nay8Constants.contactsAccess: CNAuthorizationStatus.notDetermined.rawValue,
            Nay8Constants.fullDiskAccess: true
        ])
        
        let config = ConfigurationHelper.getConfiguration()
        
        sender = Nay8()
        pluginManager = PluginManager(sender: sender, configuration: config, pluginDir: ConfigurationHelper.getPluginDirectory())
        server = Nay8WebServer(sender: sender, configuration: config.webServer)
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (ProcessInfo().arguments[safe: 1] == "-UITesting") {
            setStateForUITesting()
        }
        
        let messageDatabaseURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Messages").appendingPathComponent("chat.db")
        let viewController = NSApplication.shared.keyWindow?.contentViewController as? ViewController
		databaseHelper = DatabaseHandler(router: pluginManager.router, databaseLocation: messageDatabaseURL, diskAccessDelegate: viewController)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func setStateForUITesting() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}

