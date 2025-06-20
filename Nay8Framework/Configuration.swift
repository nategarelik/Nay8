//
//  Configuration.swift
//  Nay8 Framework
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import Foundation

class Configuration {
    struct ConfigParameters: Decodable {
        private enum CodingKeys: String, CodingKey {
            case sendStyle, actionType
        }

        let sendStyle: [String: String]
        let actionType: [Int: String]
    }
    
    static let shared = Configuration()
    
    public var parameters: ConfigParameters?
    
    init() {
        print(Bundle.main)
        let url = Bundle(for: type(of: self)).url(forResource: "Configuration", withExtension: "plist")!
        if let data = try? Data(contentsOf: url) {
            let decoder = PropertyListDecoder()
            parameters = try? decoder.decode(ConfigParameters.self, from: data)
        }
    }
}
