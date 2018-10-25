//
//  StackService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class StackService {
    
    static let sharedService = StackService()
    
    var stacks: [Stack] = []
    
    func clear() {
        self.stacks = []
    }
}
