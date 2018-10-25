//
//  BackupDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 28/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class BackupDetailCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var descrip: UILabel!
    @IBOutlet var created: UILabel!
    @IBOutlet var incremental: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Set the content of a cell according to the associated backup's index
    func setContent(index: Int) {
        let backup = BackupService.sharedService.backups[index]
        name.text = backup.name
        descrip.text = backup.descrip
        created.text = backup.created
        incremental.text = backup.incremental
        status.text = backup.status
    }
}