//
//  VolumeSnapshotDetailCell.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class VolumeSnapshotDetailCell: UITableViewCell {
    
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var size: UILabel!
    @IBOutlet var vdescription: UILabel!
    
    @IBOutlet var status: UILabel!
    @IBOutlet var volumeName: UILabel!

    @IBOutlet var vzone: UILabel!
    
    func setContent(index: Int) {
        let snapshot = VolumeSnapshotService.sharedService.snapshots[index]
        name.text = snapshot.name
        size.text = snapshot.size + "GB"
        vdescription.text = snapshot.description
        status.text = snapshot.status
        volumeName.text = snapshot.volumeName
        vzone.text = snapshot.volumeZone
        
        
    }
}
