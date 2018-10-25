//
//  ImageDetailViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/5/8.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class ImageDetailViewController: BaseViewController {
    var image: Image?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    
    @IBOutlet var imageName: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var isPublic: UILabel!
    @IBOutlet var isProtected: UILabel!
    @IBOutlet var format: UILabel!
    
    @IBOutlet var size: UILabel!
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
        
        imageName.text = image?.name
        type.text = image?.type
        status.text = image?.status
        isPublic.text = image?.isPublic
        isProtected.text = image?.isProtected
        format.text = image?.format
        size.text = image?.size
        create.text = image?.createTime
        
        
    }
    
//    func pan(gesture: UIPanGestureRecognizer) {
//        self.navigationController?.popViewControllerAnimated(true)
//    }
}
