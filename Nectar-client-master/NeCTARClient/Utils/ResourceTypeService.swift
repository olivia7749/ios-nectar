//
//  ResourceTypeService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 1/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class ResourceTypeService {
    
    static let sharedService = ResourceTypeService()
    
    var types: [ResourceType] = []
    
    func clear() {
        self.types = []
    }
}