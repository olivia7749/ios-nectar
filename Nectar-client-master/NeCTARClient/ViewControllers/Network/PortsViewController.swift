//
//  PortsViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 24/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//


import UIKit
import YXJKxMenu
import MBProgressHUD
import SwiftyJSON

// Show ports of a network
class PortsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var networkId: String = ""
    
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
            print("the ports json is")
            // Request Openstack to list ports of a network and store them into an array
            NeCTAREngine.sharedEngine.listPorts(url, token: token).then{ (json) -> Void in
                let serversArray = json["ports"].arrayValue
                var servers: [JSON] = []
                PortService.sharedService.clear()
                for server in serversArray{
                    if server["network_id"].stringValue == self.networkId {
                        servers.append(server)
                    }
                }
                if servers.count == 0 {
                    let msg = "There is no port in this network."
                    let alert = UIAlertController(title: "No Port", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let port = Port(json: server)
                        PortService.sharedService.ports.append(port!)
                    }
                    
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.tableview.reloadData()
                        self.refreshControl.endRefreshing()
                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                    }
                    
                }}.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get all ports."
                        }
                    default:
                        errorMessage = "Fail to get all ports."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
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
        btn.addTarget(self, action:#selector(PortsViewController.createPort),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(PortsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return PortService.sharedService.ports.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if PortService.sharedService.ports.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PortDetailCell") as! PortDetailCell
            cell.setContent(indexPath.row)
            cell.deleteButton.addTarget(self, action:#selector(PortsViewController.deletePort),forControlEvents:.TouchUpInside)
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    // Jump to another view controller to create a new port for the network
    func createPort(sender: UIButton){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("CreatePortViewController") as! CreatePortViewController
            editVc.networkId = self.networkId
            
            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
    // Request Openstack to delete the port from the network according to the port id
    func deletePort(sender: UIButton){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let buttonPosition:CGPoint = sender.convertPoint(CGPoint.zero, toView:self.tableview)
        let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
        let deletePortId = PortService.sharedService.ports[(indexPath?.row)!].id
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deletePort(user.networkServiceURL,portId: deletePortId, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("PortDeleted", obj: "deleted")
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



