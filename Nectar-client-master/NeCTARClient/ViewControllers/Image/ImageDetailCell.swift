//
//  ImageDetailCell.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/10.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class ImageDetailCell: UITableViewCell {

    @IBOutlet var imageName: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var size: UILabel!
    @IBOutlet var type: UILabel!
    
    func setContent(index: Int) {
        let image = ImageService.sharedService.images[index]
        imageName.text = image.name
        status.text = image.status.capitalizedString
        size.text = image.size
        type.text = image.type
        
    }
}