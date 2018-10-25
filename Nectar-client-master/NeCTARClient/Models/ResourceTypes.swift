//
//  ResourceTypes.swift
//  NeCTARClient
//
//  Created by Qi Qi on 1/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ResourceType {
    
    var type: String
    
    init?(json: JSON){
        type = json.stringValue
        
    }
}
