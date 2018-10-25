//
//  TemplateVersion.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TemplateVersion {
    
    var version: String
    var type: String
    
    init?(json: JSON){
        version = json["version"].stringValue
        type = json["type"].stringValue
    }
}

struct TemplateVersionDetail {
    var function: String
    var descrip: String
    
    init?(json: JSON) {
        function = json["functions"].stringValue
        descrip = json["description"].stringValue
    }
}

