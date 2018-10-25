//
//  FloatingIPDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 19/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

// Show all details of the floating IP
class FloatingIPDetailViewController: BaseViewController {
    var floatingIP: FloatingIP?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()
    
    @IBOutlet var ipAddress: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var fixedIpAddress: UILabel!
    @IBOutlet var descrip: UILabel!
    @IBOutlet var pool: UILabel!
    @IBOutlet var status: UILabel!
    
    
    
    var centerOfBeginning: CGPoint!
    
    // load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()

        let btn=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "deleteGrey"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action:#selector(FloatingIPDetailViewController.deleteFloatingIP),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "FloatingIPReleased", object: nil)
        
    }
    
    func statusChanged() {
        status.text = FloatingIPsService.sharedService.floatingIPs[index!].status
        self.floatingIP?.status = FloatingIPsService.sharedService.floatingIPs[index!].status
    }
    
    func returnBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func returnToRootView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setContent() {
        
        ipAddress.text = floatingIP?.ipAddress
        descrip.text = floatingIP?.descrip
        fixedIpAddress.text = floatingIP?.fixedIpAddress
        status.text = floatingIP?.status
        pool.text = floatingIP?.pool
        id.text = floatingIP?.id

        
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    // Request Openstack to delete a floating IP according to its id
    func deleteFloatingIP(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteFloatingIP((self.floatingIP?.id)!, url: user.networkServiceURL, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("FloatingIPReleased", obj: "released")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Release Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
                }.always{
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }.error{ (err) -> Void in
                    print(err)
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Action failed."
                        }
                    default:
                        errorMessage = "Action failed."
                    }
                    PromptErrorMessage(errorMessage, viewController: self, callback: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    })
            }
        }
        
    }
    
    
}

