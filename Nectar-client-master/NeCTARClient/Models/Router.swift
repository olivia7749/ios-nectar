//
//  Router.swift
//  NeCTARClient
//
//  Created by Qi Qi on 14/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Router {
    var name: String
    var status: String
    var gatewayName: String
    var networkID: String
    var subnetID: String
    var ipAddress: String
    var snat: String
    var adminState: String
    var id: String
    var projectID: String
    var adminValue: String
    
    
    
    init?(json: JSON) {
        name = json["name"].stringValue
        status = json["status"].stringValue
        id = json["id"].stringValue
        projectID = json["project_id"].stringValue
        if json["external_gateway_info"].isEmpty{
            networkID = "-"
            subnetID = "-"
            ipAddress = "-"
            gatewayName = "-"
        } else {
            networkID = json["external_gateway_info"]["network_id"].stringValue
            subnetID = json["external_gateway_info"]["external_fixed_ips"][0]["subnet_id"].stringValue
            ipAddress = json["external_gateway_info"]["external_fixed_ips"][0]["ip_address"].stringValue
            gatewayName = "gateway"

        }
        
        //        gatewayName = NeCTAREngine.sharedEngine.networkName(UserService.sharedService.user!.computeServiceURL, networkID: networkID, token: UserService.sharedService.user!.tokenID)
        
        if gatewayName != "-" {
            snat = "Enabled"
        } else {
            snat = "Not enabled"
        }
        
        
        
        
        adminValue = json["admin_state_up"].stringValue
        if adminValue == "false"{
            adminState = "DOWN"
        } else {
            adminState = "UP"
        }
    }
}
