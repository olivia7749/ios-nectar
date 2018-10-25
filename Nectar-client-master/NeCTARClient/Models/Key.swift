//
//  Key.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/20.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Key {
    
    var name: String
    var fingerprint: String
    var created: String
    var publicKey: String

    init?(json: JSON) {
        let result = json["keypair"]
        name = result["name"].stringValue
        fingerprint = result["fingerprint"].stringValue
        created = result["fingerprint"].stringValue
        publicKey = result["public_key"].stringValue

    }
    
    
}
