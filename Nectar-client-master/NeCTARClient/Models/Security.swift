//
//  Security.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON


struct Security {
    
    var name: String
    var description: String
    var id: String
    var direction: [String] = []
    var ethertype: [String] = []
    var ipProtocol: [String] = []
    var portRange: [String] = []
    var remoteIpPrefix: [String] = []
    var remoteGroupId: [String] = []
    var remoteGroupName: [String] = []
    var ruleId: [String] = []
    
    
    init?(json: JSON) {
        name = json["name"].stringValue
        description = json["description"].stringValue
        id = json["id"].stringValue
        let rule  = json["security_group_rules"].arrayValue
        for j in rule {
            direction.append(j["direction"].stringValue)
            ethertype.append(j["ethertype"].stringValue)
            ruleId.append(j["id"].stringValue)
            if j["protocol"].string != nil {
                ipProtocol.append(j["protocol"].stringValue.uppercaseString)
            } else {
                ipProtocol.append("Any")
            }
            
            if let ts = j["port_range_min"].int where ts != 0 {
                let min = j["port_range_min"].intValue
                if let ts = j["port_range_max"].int where ts != 0 {
                    let max = j["port_range_max"].intValue
                    if min == max {
                        portRange.append(String(min))
                    } else {
                        portRange.append(String(min) + " - " + String(max))
                    }
                    
                }
            } else {
                portRange.append("Any")
            }
            
            if j["remote_ip_prefix"].string != nil {
                remoteIpPrefix.append(j["remote_ip_prefix"].stringValue)
            } else {
                remoteIpPrefix.append("-")
            }
            
            if j["remote_group_id"].string != nil {
                remoteGroupId.append(j["remote_group_id"].stringValue)
            } else {
                remoteGroupId.append("-")
            }
            
            if j["remote_group_id"].string != nil {
                remoteGroupName.append(j["remote_group_id"].stringValue)
            } else {
                remoteGroupName.append("-")
            }
        }

    }
    
}