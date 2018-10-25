//
//  VolumeSnapshotService.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation

class VolumeSnapshotService {
    static let sharedService = VolumeSnapshotService()
    
    var snapshots: [VolumeSnapshot] = []
    
    func clear() {
        self.snapshots = []
    }
}
