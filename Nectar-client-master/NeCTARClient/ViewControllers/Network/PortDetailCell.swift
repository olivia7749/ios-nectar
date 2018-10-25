//
//  PortDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 24/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class PortDetailCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var fixedIps: UILabel!
    @IBOutlet var macAddress: UILabel!
    @IBOutlet var attachedDevice: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var adminState: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    
    // Set the content of a cell according to the associated port's index
    func setContent(index: Int) {
        let port = PortService.sharedService.ports[index]
        name.text = port.name
        fixedIps.text = port.fixedIps
        macAddress.text = port.macAddress
        attachedDevice.text = port.attachedDevice
        status.text = port.status
        adminState.text = port.adminState

        if name.text == "" {
            name.text = "-"
        }
        
        if fixedIps.text == "" {
            fixedIps.text = "-"
        }
        
        if attachedDevice.text == "" {
            attachedDevice.text = "Detached"
        }
    }
}
