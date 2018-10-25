//
//  AZone.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/5/9.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AZone {
    var name: String
    var state: Bool
    
    init?(json: JSON) {
        name = json["zoneName"].stringValue
        state = json["zoneState"]["available"].boolValue
    }
}
