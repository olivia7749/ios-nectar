//
//  Image.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Image {
    
    var name: String
    var status: String
    var isPublic: String
    var isProtected: String
    var format: String
    var size: String
    var id: String
    var owner: String
    var type: String
    var disk: String
    var ram: String
    var createTime: String
    
    init?(json: JSON) {
        name = json["name"].stringValue
        status = json["status"].stringValue
        let ts = json["visibility"].stringValue
        if ts == "public" {
            isPublic = "Yes"
        } else {
            isPublic = "No"
        }
        let tss = json["protected"].boolValue
        if !tss {
            isProtected = "No"
        } else {
            isProtected = "Yes"
        }
        format = json["disk_format"].stringValue.uppercaseString
        let tsss = json["size"].intValue
        if(tsss >= 1073741824) {
            size = String(round(Double(tsss) / 1073741824 * 100) / 100) + "GB"
        } else if(tsss >= 1048576) {
            size = String(round(Double(tsss) / 1048576 * 100) / 100) + "MB"
        } else if(tsss >= 1024) {
            size = String(round(Double(tsss) / 1024 * 100) / 100) + "KB"
        } else {
            size = String(tsss) + "Bytes"
        }
        id = json["id"].stringValue
        owner = json["owner"].stringValue
        
        if json["image_type"].string != nil {
            type = json["image_type"].stringValue.capitalizedString
        } else {
            type = "Image"
        }
        
        disk = String(json["min_disk"].intValue)
        ram = String(json["min_ram"].intValue)
        
        createTime = json["created_at"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ").stringByReplacingOccurrencesOfString("Z", withString: "")
    }
    

}
