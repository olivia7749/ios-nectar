//
//  PortService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 24/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class PortService {
    
    static let sharedService = PortService()
    
    var ports: [Port] = []
    
    func clear() {
        self.ports = []
    }
}