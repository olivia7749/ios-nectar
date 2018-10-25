//
//  ObjectService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class ObjectService {
    
    static let sharedService = ObjectService()
    
    var objects: [Object] = []
    
    func clear() {
        self.objects = []
    }
}