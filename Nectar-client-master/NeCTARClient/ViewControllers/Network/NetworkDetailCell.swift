//
//  NetworkDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 22/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class NetworkDetailCell: UITableViewCell {
    @IBOutlet var networkName: UILabel!
    @IBOutlet var subnetsNum: UILabel!
    @IBOutlet var shared: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var adminState: UILabel!
    @IBOutlet var external: UILabel!
    @IBOutlet var viewSubnets: UIButton!
    @IBOutlet var viewPorts: UIButton!
    
    // Set the content of a cell according to the associated network's index
    func setContent(index: Int) {
        viewSubnets.hidden = false
        viewPorts.hidden = false
        let network = NetworkService.sharedService.networks[index]
        networkName.text = network.name
        subnetsNum.text = String(network.subnets.count)
        shared.text = network.shared
        status.text = network.status
        adminState.text = network.adminState
        external.text = network.externalNetwork
        
        // Default networks don't have the function to show their networks or subnets
        let externalName = ["Classic Provider", "auckland", "monash"]
        if externalName.contains(network.name){
            viewSubnets.hidden = true
            viewPorts.hidden = true
        }
        
    }
    
}
