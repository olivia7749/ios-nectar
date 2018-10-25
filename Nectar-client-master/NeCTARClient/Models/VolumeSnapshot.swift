//
//  VolumeSnapshot.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct VolumeSnapshot {
    
    var name: String
    var description: String
    var id: String
    var size: String
    var status: String
    var volumeId: String
    var volumeName: String
    var volumeZone: String
    
    
    init?(json: JSON) {
        name = json["name"].stringValue
        description = json["description"].stringValue
        id = json["id"].stringValue
        size = String(json["size"].intValue)
        status = json["status"].stringValue
        volumeId = json["volume_id"].stringValue
        volumeName = json["volume_id"].stringValue
        volumeZone = json["volume_id"].stringValue
        
    }
    
    
}
