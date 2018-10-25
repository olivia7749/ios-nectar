//
//  RouterDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 14/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class RouterDetailCell: UITableViewCell {
    @IBOutlet var routerName: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var externalNetwork: UILabel!
    @IBOutlet var adminState: UILabel!
    
    
    // Set the content of a cell according to the associated router's index
    func setContent(index: Int) {
        let router = RouterService.sharedService.routers[index]
        routerName.text = router.name
        status.text = router.status
        externalNetwork.text = router.gatewayName
        adminState.text = router.adminState
    }
    
}