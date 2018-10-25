//
//  ImageService.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import Foundation

class ImageService {
    static let sharedService = ImageService()
    
    var images: [Image] = []
    
    func clear() {
        self.images = []
    }
}