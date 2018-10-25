//
//  ContainerService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class ContainerService {
    
    static let sharedService = ContainerService()
    
    var containers: [Container] = []
    
    func clear() {
        self.containers = []
    }
}

