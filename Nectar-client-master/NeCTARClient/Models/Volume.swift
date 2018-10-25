//
//  Volume.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Volume {
    
    var name: String
    var description: String
    var id: String
    var size: String
    var status: String
    var attachToId: String = ""
    var attachToName: String = ""
    var zone: String
    var bootable: String
    var encrypted: String
    var device: String = ""
    var create: String
    
    
    init?(json: JSON) {
        name = json["name"].stringValue
        description = json["description"].stringValue
        id = json["id"].stringValue
        size = String(json["size"].intValue)
        status = json["status"].stringValue
        
            for js in json["attachments"].arrayValue{
                attachToId = js["server_id"].stringValue
            }
        if attachToId.isEmpty {
            attachToId = "-"
        }
            
            for js in json["attachments"].arrayValue{
                attachToName = js["server_id"].stringValue
            }
        
        for js in json["attachments"].arrayValue{
            device = js["device"].stringValue
        }
        
        zone = json["availability_zone"].stringValue
        let tss = json["encrypted"].boolValue
        if !tss {
            encrypted = "No"
        } else {
            encrypted = "Yes"
        }
        let ts = json["bootable"].stringValue
        if ts == "true" {
            bootable = "Yes"
        } else {
            bootable = "No"
        }
        
        create = json["created_at"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ").stringByReplacingOccurrencesOfString("Z", withString: "").componentsSeparatedByString(".")[0]
        
    }
    
    
}
