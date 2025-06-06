//
//  AboutViewController.swift
//  Nay8UI
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBAction func updateButtonClicked(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/nategarelik/Nay8/releases")!)
    }
    @IBOutlet weak var versionField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionField.stringValue = "Version \(bundleShortVersion ?? "??") (\(bundleVersion ?? "0"))"
    }
}
