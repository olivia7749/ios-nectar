//
//  VolumeDetailViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/5/8.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class VolumeDetailViewController: BaseViewController {
    var volume: Volume?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var size: UILabel!
    @IBOutlet var vdescription: UILabel!
    
    @IBOutlet var status: UILabel!
    @IBOutlet var instanceName: UILabel!
    
    @IBOutlet var encrypted: UILabel!
    @IBOutlet var bootable: UILabel!
    @IBOutlet var azone: UILabel!
    @IBOutlet var create: UILabel!
    
    
    // load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        
        //panGesture.addTarget(self, action: #selector(pan(_:)))
        //self.view.addGestureRecognizer(panGesture)
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnToRootView), name: "InstanceDeleted", object: nil)
        
    }
    //    func statusChanged() {
    //        status.text = InstanceService.sharedService.instances[index!].status
    //        self.instance?.status = InstanceService.sharedService.instances[index!].status
    //    }
    //
    //    func returnToRootView() {
    //        self.navigationController?.popToRootViewControllerAnimated(true)
    //    }
    
    func setContent() {
        
        name.text = volume!.name
        size.text = volume!.size + "GB"
        vdescription.text = volume!.description
        status.text = volume!.status
        if (!volume!.attachToName.isEmpty) {
            instanceName.text = volume!.attachToName + " on " + volume!.device
            
        } else {
            instanceName.text = volume!.attachToName
        }
        
        encrypted.text = volume!.encrypted
        bootable.text = volume!.bootable
        azone.text = volume!.zone
        create.text = volume!.create
        
        
    }
    
    //    func pan(gesture: UIPanGestureRecognizer) {
    //        self.navigationController?.popViewControllerAnimated(true)
    //    }
}

