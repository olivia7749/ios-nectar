//
//  TemplateVersionService.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import Foundation

class TemplateVersionService {
    
    static let sharedService = TemplateVersionService()
    
    var templateVersions: [TemplateVersion] = []
    var templateDetails: [[TemplateVersionDetail]] = []
    
    func clear() {
        self.templateVersions = []
        self.templateDetails = []
    }
    
    func clearDetail(index: Int) {
        self.templateDetails[index] = []
    }
}
