//
//  ViewController.swift
//  JaredUI
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Cocoa
import Contacts

class ViewController: NSViewController, DiskAccessDelegate {
    let observeKeys = [
        GarelikAssistantConstants.garelikAssistantIsDisabled,
        GarelikAssistantConstants.restApiIsDisabled,
        GarelikAssistantConstants.contactsAccess,
        GarelikAssistantConstants.sendMessageAccess,
        GarelikAssistantConstants.fullDiskAccess
    ]
    var defaults: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = UserDefaults.standard
        let _ = PermissionsHelper.canSendMessages()
        
        observeKeys.forEach { path in
            defaults.addObserver(self, forKeyPath: path, options: .new, context: nil)
        }
        
        updateTouchBarButton()
    }
    
    deinit {
        if #available(OSX 10.12.2, *) {
            self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
        }
        UserDefaults.standard.removeObserver(self, forKeyPath: GarelikAssistantConstants.garelikAssistantIsDisabled)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        if #available(OSX 10.12.2, *) {
            self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar))) // unbind first
            self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }
        
        if observeKeys.contains(keyPath) {
            updateTouchBarButton()
        }
    }
    
    func updateTouchBarButton() {
        DispatchQueue.main.async{
            let noDiskAccess = !self.defaults.bool(forKey: GarelikAssistantConstants.fullDiskAccess)
            
            if (self.defaults.bool(forKey: GarelikAssistantConstants.garelikAssistantIsDisabled) || noDiskAccess) {
                self.EnableDisableButton.title = "Enable"
                self.EnableDisableUiButton.title = "Enable GarelikAssistant"
                self.JaredStatusLabel.stringValue = "GarelikAssistant is currently disabled"
                self.statusImage.image = NSImage(named: NSImage.statusUnavailableName)
            }
            else {
                self.EnableDisableButton.title = "Disable"
                self.EnableDisableUiButton.title = "Disable Jared"
                self.JaredStatusLabel.stringValue = "GarelikAssistant is currently enabled"
                self.statusImage.image = NSImage(named: NSImage.statusAvailableName)
            }
            
            if(noDiskAccess) {
                self.EnableDisableUiButton.title = "Enable Disk Access"
                self.EnableDisableButton.title = "Enable Disk Access"
            }
            
            if (self.defaults.bool(forKey: GarelikAssistantConstants.restApiIsDisabled)) {
                self.EnableDisableRestApiUiButton.title = "Enable API"
                self.RestApiStatusLabel.stringValue = "REST API is currently disabled"
                self.RestApiStatusImage.image = NSImage(named: NSImage.statusUnavailableName)
            }
            else {
                self.EnableDisableRestApiUiButton.title = "Disable API"
                self.RestApiStatusLabel.stringValue = "REST API is currently enabled"
                self.RestApiStatusImage.image = NSImage(named: NSImage.statusAvailableName)
            }
            
            switch(CNAuthorizationStatus(rawValue: self.defaults.integer(forKey: GarelikAssistantConstants.contactsAccess))) {
            case .notDetermined:
                self.contactsLabel.stringValue = "Contacts access not set"
                self.contactsButton.title = "Enable Contacts"
                self.contactsStatusImage.image = NSImage(named: NSImage.statusPartiallyAvailableName)
                break
            case .authorized:
                self.contactsLabel.stringValue = "Contacts access authorized"
                self.contactsButton.title = "Manage Contacts"
                self.contactsStatusImage.image = NSImage(named: NSImage.statusAvailableName)
                break
            case .denied:
                self.contactsLabel.stringValue = "Contacts access denied"
                self.contactsStatusImage.image = NSImage(named: NSImage.statusUnavailableName)
                break
            case .restricted:
                self.contactsLabel.stringValue = "Contacts access restricted"
                self.contactsStatusImage.image = NSImage(named: NSImage.statusUnavailableName)
                break
            default:
                self.contactsButton.title = "Manage Contacts"
                self.contactsStatusImage.image = NSImage(named: NSImage.statusUnavailableName)
                break
            }
            
            switch(AutomationPermissionState(rawValue: self.defaults.integer(forKey: GarelikAssistantConstants.sendMessageAccess))) {
            case .authorized:
                self.sendStatusLabel.stringValue = "GarelikAssistant can send messages"
                self.sendStatusImage.image = NSImage(named: NSImage.statusAvailableName)
                self.sendStatusButton.title = "Manage automation"
                
                if #available(OSX 10.14, *) {
                    self.sendStatusButton.isEnabled = true
                } else {
                    self.sendStatusButton.isEnabled = false
                }
            case .declined:
                self.sendStatusLabel.stringValue = "Jared not permitted to send messages."
                self.sendStatusImage.image = NSImage(named: NSImage.statusUnavailableName)
                self.sendStatusButton.title = "Manage automation"
            case .notDetermined:
                self.sendStatusLabel.stringValue = "Messages automation permissions not set."
                self.sendStatusImage.image = NSImage(named: NSImage.statusPartiallyAvailableName)
                self.sendStatusButton.title = "Enable automation"
            case .notRunning:
                self.sendStatusLabel.stringValue = "GarelikAssistant cannot check send permissions because Messages is not open"
                self.sendStatusImage.image = NSImage(named: NSImage.statusPartiallyAvailableName)
                self.sendStatusButton.title = "Recheck"
            case .none, .unknown:
                self.sendStatusLabel.stringValue = "Messages automation status unkown"
                self.sendStatusImage.image = NSImage(named: NSImage.statusPartiallyAvailableName)
                self.sendStatusButton.title = "Manage automation"
            }
        }
    }
    
    func displayAccessError() {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Permission Error"
        alert.informativeText = "GarelikAssistant requires \"full disk access\" to access the Messages database. This is an OS level restriction and can be enabled in System Preferences."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSImage(named: NSImage.cautionName)
        
        let res = alert.runModal()
        
        if(res == NSApplication.ModalResponse.alertFirstButtonReturn) {
            NSWorkspace.shared.open(URL(string: GarelikAssistantConstants.fullDiskAcccessUrl)!)
        }
    }
    
    @IBOutlet weak var JaredStatusLabel: NSTextField!
    @IBOutlet weak var EnableDisableUiButton: NSButton!
    @IBOutlet weak var EnableDisableButton: NSButtonCell!
    @IBOutlet weak var EnableDisableRestApiUiButton: NSButton!
    @IBOutlet weak var RestApiStatusLabel: NSTextField!
    @IBOutlet weak var RestApiStatusImage: NSImageView!
    @IBOutlet weak var statusImage: NSImageView!
    @IBOutlet weak var contactsStatusImage: NSImageView!
    @IBOutlet weak var contactsLabel: NSTextField!
    @IBOutlet weak var contactsButton: NSButton!
    @IBOutlet weak var sendStatusImage: NSImageView!
    @IBOutlet weak var sendStatusLabel: NSTextField!
    @IBOutlet weak var sendStatusButton: NSButton!
    
    @IBAction func EnableDisableAction(_ sender: Any) {
        if (defaults.bool(forKey: GarelikAssistantConstants.fullDiskAccess)) {
            if (defaults.bool(forKey: GarelikAssistantConstants.garelikAssistantIsDisabled)) {
                defaults.set(false, forKey: GarelikAssistantConstants.garelikAssistantIsDisabled)
            } else {
                defaults.set(true, forKey: GarelikAssistantConstants.garelikAssistantIsDisabled)
            }
        } else {
            NSWorkspace.shared.open(URL(string: GarelikAssistantConstants.fullDiskAcccessUrl)!)
        }
    }
    
    @IBAction func EnableDisableRestApiAction(_ sender: Any) {
        if (defaults.bool(forKey: GarelikAssistantConstants.restApiIsDisabled)) {
            defaults.set(false, forKey: GarelikAssistantConstants.restApiIsDisabled)
        }
        else {
            defaults.set(true, forKey: GarelikAssistantConstants.restApiIsDisabled)
        }
    }
    
    @IBAction func contactsButtonAction(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            switch(CNAuthorizationStatus(rawValue: self.defaults.integer(forKey: GarelikAssistantConstants.contactsAccess))) {
            case .notDetermined:
                PermissionsHelper.requestContactsAccess()
                return
            default:
                NSWorkspace.shared.open(URL(string: GarelikAssistantConstants.contactsAccessUrl)!)
            }
        }
    }
    
    @IBAction func sendStatusButtonAction(_ sender: Any) {
        if #available(OSX 10.14, *) {
            switch(PermissionsHelper.canSendMessages()) {
            case .notRunning:
                NSWorkspace.shared.open(URL(string: GarelikAssistantConstants.messagesUrl)!)
                sendStatusButtonAction(sender)
                break
            case .authorized, .declined, .unknown:
                NSWorkspace.shared.open(URL(string: GarelikAssistantConstants.automationAccessUrl)!)
                break
            case .notDetermined:
                PermissionsHelper.requestMessageAutomation()
            }
        }
    }
    
    @IBAction func OpenPluginsButtonAction(_ sender: Any) {
        let filemanager = FileManager.default
        let appsupport = filemanager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let supportDir = appsupport.appendingPathComponent("GarelikAssistant")
        let pluginDir = supportDir.appendingPathComponent("Plugins")
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: pluginDir.path)
    }
    @IBAction func ReloadButtonPressed(_ sender: Any) {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.pluginManager.reload()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
