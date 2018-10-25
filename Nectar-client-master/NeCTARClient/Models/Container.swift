//
//  Container.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Container {
    
    var count: String
    var bytes: String
    var name: String
    //var lastModified: String
    
    init?(json: JSON){
        count = json["count"].stringValue
        bytes = json["bytes"].stringValue
        name = json["name"].stringValue
        //lastModified = json["last_modified"].stringValue
        
    }
}