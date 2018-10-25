//
//  SubnetService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 23/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class SubnetService {
    
    static let sharedService = SubnetService()
    
    var subnets: [Subnet] = []
    
    func clear() {
        self.subnets = []
    }
}
