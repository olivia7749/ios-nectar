//
//  InstanceDetailViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/9/18.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class InstanceDetailViewController: BaseViewController {
    var instance: Instance?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    
    @IBOutlet var instanceName: UILabel!
    @IBOutlet var imageName: UILabel!
    @IBOutlet var ipAddress: UILabel!
    @IBOutlet var keyPair: UILabel!
    @IBOutlet var size: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var createTime: UILabel!
    
    @IBOutlet var security: UILabel!
    @IBOutlet var actions: UIButton!
    
    @IBOutlet var azone: UILabel!
    @IBOutlet var volume: UILabel!
    
    var actionViewController: ActionsViewController!
    var centerOfBeginning: CGPoint!
    
    // load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        
        //panGesture.addTarget(self, action: #selector(pan(_:)))
        //self.view.addGestureRecognizer(panGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnToRootView), name: "InstanceDeleted", object: nil)

    }
    func statusChanged() {
        status.text = InstanceService.sharedService.instances[index!].status
        self.instance?.status = InstanceService.sharedService.instances[index!].status
    }
    
    func returnToRootView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setContent() {
        
        instanceName.text = instance!.name
        imageName.text = instance!.imageRel
        ipAddress.text = instance!.ip4Address
        keyPair.text = instance!.keyName
        size.text = FlavorService.sharedService.findFlavors(instance!.flavorRel)
        status.text = instance!.status
        createTime.text = instance!.createTime
        security.text = instance!.security
        volume.text = instance!.volumesName
        azone.text = instance!.zone
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func actionsOnClick(sender: AnyObject) {
        showActionMenu()
    }
    
    func showActionMenu() {
        actionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Action") as! ActionsViewController
        let image = imageWithCaptureView((self.navigationController?.view)!)
        actionViewController.backImage = image
        actionViewController.instance = self.instance
        actionViewController.instanceIndex = self.index
        
        self.presentViewController(actionViewController, animated: false, completion: nil)
    }
}
