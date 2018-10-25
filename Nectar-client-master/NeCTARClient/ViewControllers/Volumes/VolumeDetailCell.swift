//
//  VolumeDetailCell.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class VolumeDetailCell: UITableViewCell {
    
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var size: UILabel!
    @IBOutlet var vdescription: UILabel!
    
    @IBOutlet var status: UILabel!
    @IBOutlet var instanceName: UILabel!
    
    func setContent(index: Int) {
        let volume = VolumeService.sharedService.volumes[index]
        name.text = volume.name
        size.text = volume.size + "GB"
        vdescription.text = volume.description
        status.text = volume.status
        if (!volume.attachToName.isEmpty) {
            instanceName.text = volume.attachToName + " on " + volume.device

        } else {
            instanceName.text = volume.attachToName
        }
        
        
        
    }
}
