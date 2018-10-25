//
//  ConfigurationGroup.swift
//  NeCTARClient
//
//  Created by Qi Qi on 29/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class ConfigurationGroupService {
    
    static let sharedService = ConfigurationGroupService()
    
    var configutationGroups: [ConfigurationGroup] = []
    
    func clear() {
        self.configutationGroups = []
    }
}
