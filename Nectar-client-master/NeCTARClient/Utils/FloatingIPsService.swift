//
//  FloatingIPsService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 19/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class FloatingIPsService {
    
    static let sharedService = FloatingIPsService()
    
    var floatingIPs: [FloatingIP] = []
    
    func clear() {
        self.floatingIPs = []
    }
}
