//
//  BackupService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 28/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class BackupService {
    
    static let sharedService = BackupService()
    
    var backups: [Backup] = []
    
    func clear() {
        self.backups = []
    }
}
