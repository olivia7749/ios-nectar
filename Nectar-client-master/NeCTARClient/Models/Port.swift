//
//  Port.swift
//  NeCTARClient
//
//  Created by Qi Qi on 24/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Port {
    
    var name: String
    var id: String
    var fixedIps: String = ""
    var macAddress: String
    var attachedDevice: String
    var status: String
    var adminState: String
    
    init?(json: JSON){
        name = json["name"].stringValue
        id = json["id"].stringValue
        
        let fixedIpsValue = json["fixed_ips"].arrayValue
        for ip in fixedIpsValue {
            fixedIps = fixedIps + " " + ip["ip_address"].stringValue
        }
        
        macAddress = json["mac_address"].stringValue
        attachedDevice = json["device_owner"].stringValue
        status = json["status"].stringValue
        
        let adminValue = json["admin_state_up"].stringValue
        if adminValue == "false"{
            adminState = "DOWN"
        } else {
            adminState = "UP"
        }


    }
}


