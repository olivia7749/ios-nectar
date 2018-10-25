//
//  FlavorService.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/10/1.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation

class FlavorService {
    static let sharedService = FlavorService()
    
    var falvors: [Flavor] = []
    
    func clear() {
        self.falvors = []
    }
    
    func findFlavors(herf: String) -> String {
        for flavor in falvors {
            if (herf == flavor.herf) {
                return flavor.name
            }
        }
        return "Size"
    }
}