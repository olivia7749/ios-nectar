//
//  SubnetsViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 23/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

// Show subnets of a network
class SubnetsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var networkId: String = ""
    var subnetsId: [String] = []
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.networkServiceURL
            let token = user.tokenID
            
            SubnetService.sharedService.clear()
            
            if subnetsId.count == 0 {
                let msg = "There is no subnet in this network."
                let alert = UIAlertController(title: "No Subnet", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            } else {
                for subnetid in subnetsId {
                    
                    // Request Openstack to list subnets of a network and store them into an array
                    NeCTAREngine.sharedEngine.querySubnet(url, token: token, subnetID: subnetid).then{ (json) -> Void in
                        
                        print("subnet json")
                        print(json)
                        let subnet = Subnet(json: json)
                        SubnetService.sharedService.subnets.append(subnet!)
                        
                        }.error{(err) -> Void in
                            var errorMessage:String = "Action Failed."
                            switch err {
                            case NeCTAREngineError.CommonError(let msg):
                                errorMessage = msg!
                                
                            case NeCTAREngineError.ErrorStatusCode(let code):
                                if code == 401 {
                                    loginRequired()
                                } else {
                                    errorMessage = "Fail to get the subnet."
                                }
                            default:
                                errorMessage = "Fail to get the subnet."
                            }
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
                    
                    
                }
                
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.tableview.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }
                
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        let btn=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action:#selector(SubnetsViewController.createSubnet),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(SubnetsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        commonInit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
        
        
        
    }
    
    
    
    func statusChanged() {
        self.tableview.reloadData()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubnetService.sharedService.subnets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if SubnetService.sharedService.subnets.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SubnetDetailCell") as! SubnetDetailCell
            cell.setContent(indexPath.row)
            cell.deleteButton.addTarget(self, action:#selector(SubnetsViewController.deleteSubnet),forControlEvents:.TouchUpInside)
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    // Jump to another view controller to create a new subnet for the network
    func createSubnet(sender: UIButton){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("CreateSubnetViewController") as! CreateSubnetViewController
            
            editVc.networkId = self.networkId
            
            
            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
    // Request Openstack to delete the subnet from the network according to the subnet id
    func deleteSubnet(sender: UIButton){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let buttonPosition:CGPoint = sender.convertPoint(CGPoint.zero, toView:self.tableview)
        let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
        let deleteSubnetId = self.subnetsId[(indexPath?.row)!]
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteSubnet(user.networkServiceURL,subnetId: deleteSubnetId, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("SubnetDeleted", obj: "deleted")
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
                            
                            errorMessage = "Unable to delete the subnet, because one or more ports have an IP allocation from this subnet."
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


