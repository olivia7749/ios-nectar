//
//  InstanceService.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/21.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation

class InstanceService {
    static let sharedService = InstanceService()
    
    var instances: [Instance] = []
    
    func clear() {
        self.instances = []
    }
}