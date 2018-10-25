//
//  KeyService.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/20.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation

class KeyService {
    static let sharedService = KeyService()
    
    var keys: [Key] = []
    
    func clear() {
        self.keys = []
    }
}