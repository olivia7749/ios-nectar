//
//  Instances.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/21.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Instance {
    var ip4Address: String
    var addresses: [String] = []
    var createTime: String
    var flavorID: String
    var flavorRel: String
    var hostId: String
    var id: String
    var imageId: String
    var imageRel: String
    var keyName: String
    var name: String
    var taskState: String
    var status: String
    var volumes: [String] = []
    var volumesName: String = ""
    var security: String = ""
    var zone: String
    
    init?(json: JSON) {
        ip4Address = json["accessIPv4"].stringValue
        let address = json["address"]["private"].arrayValue
        for j in address {
            addresses.append(j["addr"].stringValue)
        }
        createTime = json["created"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ").stringByReplacingOccurrencesOfString("Z", withString: "")
        flavorID = json["flavor"]["id"].stringValue
        flavorRel = json["flavor"]["links"][0]["href"].stringValue
        hostId = json["hostId"].stringValue
        id = json["id"].stringValue
        imageId = json["image"]["id"].stringValue
        imageRel = json["image"]["links"][0]["rel"].stringValue
        zone = json["OS-EXT-AZ:availability_zone"].stringValue
        
        if let key = json["key_name"].string where !key.isEmpty{
            keyName = key
        } else {
            keyName = "-"

        }
        
        //keyName = json["key_name"].stringValue
        name = json["name"].stringValue
//        var ts = json["OS-EXT-STS:task_state"]
        if let ts = json["OS-EXT-STS:task_state"].string where !ts.isEmpty  {
            taskState = ts
        } else {
            taskState = "no task"
        }
        
        status = json["status"].stringValue
        
        for js in json["os-extended-volumes:volumes_attached"].arrayValue {
            volumes.append(js["id"].stringValue)
        }
        
        if volumes.isEmpty {
            volumes.append("No volumes attached")
        }
        
        for js in json["os-extended-volumes:volumes_attached"].arrayValue{
            volumesName = volumesName + js["os-extended-volumes:volumes_attached"].stringValue + "; "
        }
        
        if volumesName.isEmpty {
            volumesName = "No volumes attached"
        }
        
        for js in json["security_groups"].arrayValue{
            security = security + js["name"].stringValue + "; " 
        }
    }
    
}
