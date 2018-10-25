//
//  FloatingIP.swift
//  NeCTARClient
//
//  Created by Qi Qi on 19/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FloatingIP {
    
    var id: String
    var ipAddress: String
    var descrip: String
    var pool: String
    var status: String
    var tenantId: String
    var projectId: String
    var floatingNetworkId: String
    var fixedIpAddress: String
    
    
    init?(json: JSON){
        ipAddress = json["floating_ip_address"].stringValue
        descrip = json["description"].stringValue
        id = json["id"].stringValue
        status = json["status"].stringValue
        tenantId = json["tenant_id"].stringValue
        projectId = json["project_id"].stringValue
        floatingNetworkId = json["floating_network_id"].stringValue
        pool = "pool"
        fixedIpAddress = json["fixed_ip_address"].stringValue
        if fixedIpAddress == "" {
            fixedIpAddress = "-"
        }
        
    }
}
