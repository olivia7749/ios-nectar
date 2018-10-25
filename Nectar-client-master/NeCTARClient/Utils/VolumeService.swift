//
//  VolumeService.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation

class VolumeService {
    static let sharedService = VolumeService()
    
    var volumes: [Volume] = []
    
    func clear() {
        self.volumes = []
    }
}