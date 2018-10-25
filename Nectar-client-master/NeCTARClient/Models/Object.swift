//
//  Object.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Object {
    
    var name: String
    var contentType: String
    var bytes: String
    var lastModified: String
    var hashList: String
    
    init?(json: JSON){
        name = json["name"].stringValue
        contentType = json["content_type"].stringValue
        bytes = json["bytes"].stringValue
        lastModified = json["last_modified"].stringValue
        hashList = json["hash"].stringValue
        
    }
}
