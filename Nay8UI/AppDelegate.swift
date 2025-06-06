//
//  AppDelegate.swift
//  JaredUI
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Cocoa
import Contacts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var sender: GarelikAssistant
    var pluginManager: PluginManager
    var server: JaredWebServer
    var databaseHelper: DatabaseHandler!
    override init() {
        UserDefaults.standard.register(defaults: [
            GarelikAssistantConstants.garelikAssistantIsDisabled: false,
            GarelikAssistantConstants.restApiIsDisabled: true,
            GarelikAssistantConstants.contactsAccess: CNAuthorizationStatus.notDetermined.rawValue,
            GarelikAssistantConstants.fullDiskAccess: true
        ])
        
        let config = ConfigurationHelper.getConfiguration()
        
        sender = GarelikAssistant()
        pluginManager = PluginManager(sender: sender, configuration: config, pluginDir: ConfigurationHelper.getPluginDirectory())
        server = JaredWebServer(sender: sender, configuration: config.webServer)
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

