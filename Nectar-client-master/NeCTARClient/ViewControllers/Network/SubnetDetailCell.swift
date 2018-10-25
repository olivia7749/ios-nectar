//
//  SubnetDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 23/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class SubnetDetailCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var subnetPool: UILabel!
    @IBOutlet var ipVersion: UILabel!
    @IBOutlet var cidr: UILabel!
    @IBOutlet var ipAllocationPools: UILabel!
    @IBOutlet var gatewayIp: UILabel!
    @IBOutlet var dhcpEnabled: UILabel!
    @IBOutlet var dnsNameServers: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Set the content of a cell according to the associated subnet's index
    func setContent(index: Int) {
        let subnet = SubnetService.sharedService.subnets[index]
        name.text = subnet.name
        id.text = subnet.id
        subnetPool.text = subnet.subnetPool
        ipVersion.text = subnet.ipVersion
        cidr.text = subnet.cidr
        ipAllocationPools.text = subnet.ipAllocationPools
        gatewayIp.text = subnet.gatewayIp
        dhcpEnabled.text = subnet.dhcpEnabled
        dnsNameServers.text = subnet.dnsNameServers
    }
}


