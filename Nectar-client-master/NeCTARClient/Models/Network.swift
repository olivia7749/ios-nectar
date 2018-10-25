//
//  Network.swift
//  NeCTARClient
//
//  Created by Qi Qi on 15/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Network {
    var name: String
    var id: String
    var projectID: String
    var status: String
    var adminState: String
    var shared: String
    var externalNetwork: String
    var mtu: String
    var subnets: [String] = []
    var tennantId: String
    //    var ipAddress: String
    //    var subnetId: String
    
    
    
    init?(json: JSON) {
        name = json["name"].stringValue
        id = json["id"].stringValue
        projectID = json["project_id"].stringValue
        status = json["status"].stringValue
        tennantId = json["tenant_id"].stringValue
        
        let adminValue = json["admin_state_up"].stringValue
        if adminValue == "false"{
            adminState = "DOWN"
        } else {
            adminState = "UP"
        }
        
        let sharedValue = json["shared"].stringValue
        if sharedValue == "true"{
            shared = "Yes"
        } else {
            shared = "No"
        }
        
        let externalNetworkValue = json["router:external"].stringValue
        if externalNetworkValue == "true"{
            externalNetwork = "Yes"
        } else {
            externalNetwork = "No"
        }
        
        if json["mtu"].stringValue != "" {
            mtu = json["mtu"].stringValue
        } else {
            mtu = "Unknown"
        }
        
        let subnetArray = json["subnets"].arrayValue
        for js in subnetArray {
            if js.stringValue != ""{
                
                subnets.append(js.stringValue)
            }
            
        }
        
        
    }
    
}
