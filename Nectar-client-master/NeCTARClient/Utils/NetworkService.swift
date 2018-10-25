//
//  NetworkService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 15/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class NetworkService {
    static let sharedService = NetworkService()
    
    var networks: [Network] = []
    
    func clear() {
        self.networks = []
    }
}