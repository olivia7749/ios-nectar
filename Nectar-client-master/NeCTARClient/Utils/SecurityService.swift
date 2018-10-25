//
//  SecurityService.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation

class SecurityService {
    static let sharedService = SecurityService()
    
    var securities: [Security] = []
    
    func clear() {
        self.securities = []
    }
}
