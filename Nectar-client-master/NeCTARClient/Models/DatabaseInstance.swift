//
//  DatabaseInstance.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DatabaseInstance {
    
    var name: String
    var id: String
    var datastore: String
    var datastoreVersion: String
    var status: String
    var rootEnabled: String
    var flavorId: String
    var flavorName: String
    //var ram: String
    var volumeSize: String
    var created: String
    var updated: String
    //var host: String
    //var databasePort: String
    
    
    init?(json: JSON){
        name = json["instance"]["name"].stringValue
        id = json["instance"]["id"].stringValue
        datastore = json["instance"]["datastore"]["type"].stringValue
        datastoreVersion = json["instance"]["datastore"]["version"].stringValue
        status = json["instance"]["status"].stringValue
        flavorId = json["instance"]["flavor"]["id"].stringValue
        volumeSize = json["instance"]["volume"]["size"].stringValue
        created = json["instance"]["created"].stringValue
        updated = json["instance"]["updated"].stringValue
        rootEnabled = "-"
        flavorName = "-"
        
    }
}


