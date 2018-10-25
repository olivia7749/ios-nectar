//
//  Configuration.swift
//  NeCTARClient
//
//  Created by Qi Qi on 29/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ConfigurationGroup {
    
    var name: String
    var descrip: String
    var id: String
    var datastore: String
    var created: String
    var updated: String
    
    init?(json: JSON){
        name = json["name"].stringValue
        descrip = json["description"].stringValue
        if descrip == "" {
            descrip = "-"
        }
        id = json["id"].stringValue
        created = json["created"].stringValue
        updated = json["updated"].stringValue
        datastore = json["datastore_name"].stringValue + " " + json["datastore_version_name"].stringValue
        
    }
}

