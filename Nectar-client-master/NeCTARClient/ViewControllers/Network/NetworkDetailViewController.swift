//
//  NetworkDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 23/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

// Show detail interface of a network
class NetworkDetailViewController: BaseViewController {
    var network: Network?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()
    
    @IBOutlet var networkName: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var projectId: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var adminState: UILabel!
    @IBOutlet var shared: UILabel!
    @IBOutlet var externalNetwork: UILabel!
    @IBOutlet var subnetsNum: UILabel!
    @IBOutlet var mtu: UILabel!
    
    var actionViewController: ActionsViewController!
    var centerOfBeginning: CGPoint!
    
    // load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        
        let externalName = ["Classic Provider", "auckland", "monash"]
        // Add delete button to networks except default networks
        if externalName.contains(network!.name) == false {
            
            let btn=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
            btn.setImage(UIImage(named: "deleteGrey"), forState: UIControlState.Highlighted)
            btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn.addTarget(self, action:#selector(NetworkDetailViewController.deleteNetwork),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem=item2
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "NetworkDeleted", object: nil)
        }
        
    }
    
    func statusChanged() {
        status.text = NetworkService.sharedService.networks[index!].status
        self.network?.status = NetworkService.sharedService.networks[index!].status
    }
    
    func returnBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func returnToRootView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Set contents that will be showed in the interface
    func setContent() {
        
        networkName.text = network?.name
        id.text = network?.id
        projectId.text = network?.projectID
        status.text = network?.status
        adminState.text = network?.adminState
        shared.text = network?.shared
        externalNetwork.text = network?.externalNetwork
        subnetsNum.text = String(network!.subnets.count)
        mtu.text = network?.mtu
        
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
    
    func deleteNetwork(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            
            // Request Openstack to delete a network according to its id
            NeCTAREngine.sharedEngine.deleteNetwork(user.networkServiceURL, networkID: self.network!.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("NetworkdDeleted", obj: "deleted")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Delete Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
                        } else if code == 409 {
                            
                            errorMessage = "Unable to delete the network, because one or more ports still exist on the requested network."
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
