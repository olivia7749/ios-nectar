//
//  AZoneService.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/5/9.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation

class AZoneService {
    static let sharedService = AZoneService()
    
    var azones: [AZone] = []
    
    func clear() {
        self.azones = []
    }
}
