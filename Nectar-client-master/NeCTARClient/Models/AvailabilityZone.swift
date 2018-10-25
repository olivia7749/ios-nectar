//
//  AvailabilityZone.swift
//  NeCTARClient
//
//  Created by Qi Qi on 30/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AvailabilityZone {
    
    var name: String
    
    init?(json: JSON){
        name = json["zoneName"].stringValue
        
    }
}


