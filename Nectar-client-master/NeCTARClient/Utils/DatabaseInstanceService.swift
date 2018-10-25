//
//  DatabaseInstanceService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class DatabaseInstanceService {
    
    static let sharedService = DatabaseInstanceService()
    var unusedVolumeSize: [String] = []
    var databaseInstances: [DatabaseInstance] = []
    
    func clear() {
        self.databaseInstances = []
    }
}