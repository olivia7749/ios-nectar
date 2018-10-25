//
//  AvailabZoneService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 30/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class AvailabZoneService {
    
    static let sharedService = AvailabZoneService()
    
    var availabZones: [AvailabilityZone] = []
    
    func clear() {
        self.availabZones = []
    }
}
