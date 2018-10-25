//
//  RouterService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 14/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class RouterService {
    static let sharedService = RouterService()
    
    var routers: [Router] = []
    
    func clear() {
        self.routers = []
    }
}