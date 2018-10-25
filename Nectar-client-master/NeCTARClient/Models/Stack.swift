//
//  Stack.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Stack {
    
    var name: String
    var descrip: String
    var created: String
    var updated: String
    var status: String
    var id:String
    var rollback: String = "-"
    var statusReason: String
    
    init?(json: JSON){
        name = json["stack_name"].stringValue
        created = json["creation_time"].stringValue
        updated = json["updated_time"].stringValue
        id = json["id"].stringValue
        statusReason = json["stack_status_reason"].stringValue
        if updated == "" {
            updated = "Never"
        }
        descrip = json["description"].stringValue
        if descrip == "" {
            descrip = "-"
        }
        status = json["stack_status"].stringValue
    }
}
