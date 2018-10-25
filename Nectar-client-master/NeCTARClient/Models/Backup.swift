//
//  Backup.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Backup {
    
    var name: String
    var descrip: String
    var id: String
    var created: String
    var incremental: String
    var status: String
    
    
    init?(json: JSON){
        name = json["name"].stringValue
        descrip = json["description"].stringValue
        id = json["id"].stringValue
        created = json["created"].stringValue
        incremental = json["parent_id"].stringValue
        status = json["status"].stringValue
        if descrip == "" {
            descrip = "-"
        }
        if incremental == "" {
            incremental = "No"
        }
        
    }
}


