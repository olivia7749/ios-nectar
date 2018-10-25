//
//  FloatingIPsViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 19/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

// Show floating IPs in a table view
class FloatingIPsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.networkServiceURL
            let token = user.tokenID
            print("The floating IP url is \(url)")
            
             // Request Openstack to return a json file that contains floating IPs information, and store them in an array
            NeCTAREngine.sharedEngine.listFloatingIPs(url, token: token).then{ (json) -> Void in
                let servers = json["floatingips"].arrayValue
                FloatingIPsService.sharedService.clear()
                var index1 = 0
                print("Floating IP json")
                print(json)
                print(servers.count)
                
                if servers.count == 0 {
                    let msg = "There is no floating IP."
                    let alert = UIAlertController(title: "No Floating IP", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let floatingIP = FloatingIP(json: server)
                        FloatingIPsService.sharedService.floatingIPs.append(floatingIP!)
                        
                        NeCTAREngine.sharedEngine.queryNetwork(user.networkServiceURL, token: token, networkID: (floatingIP?.floatingNetworkId)!).then{(json2) -> Void in
                            let externalNetworkName = json2["network"]["name"].stringValue
                            
                            
                            FloatingIPsService.sharedService.floatingIPs[index1].pool = externalNetworkName
                            print(externalNetworkName)
                            index1 += 1
                            
                            }.error{(err) -> Void in
                                var errorMessage:String = "Action Failed."
                                switch err {
                                case NeCTAREngineError.CommonError(let msg):
                                    errorMessage = msg!
                                case NeCTAREngineError.ErrorStatusCode(let code):
                                    if code == 401 {
                                        loginRequired()
                                    }else {
                                        errorMessage = "Fail to get all the pool detail"
                                    }
                                default:
                                    errorMessage = "Fail to get all the pool detail"
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
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get all floating IPs."
                        }
                    default:
                        errorMessage = "Fail to get all floating IPs."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(FloatingIPsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return FloatingIPsService.sharedService.floatingIPs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if FloatingIPsService.sharedService.floatingIPs.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FloatingIPDetail") as! FloatingIPDetailCell
            cell.setContent(indexPath.row)
            
            print("floating ips! \(FloatingIPsService.sharedService.floatingIPs)")
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Jump to the interface that show details of the floating IP once the cell is clicked
        if segue.identifier == "ShowFloatingIPDetail" {
            let cell = sender as! FloatingIPDetailCell
            let path = self.tableview.indexPathForCell(cell)

            let detailVC = segue.destinationViewController as! FloatingIPDetailViewController
            detailVC.navigationItem.title = "Floating IP Detail"
            detailVC.floatingIP = FloatingIPsService.sharedService.floatingIPs[(path?.row)!]
            detailVC.index = path?.row

            
        }
    }    

}

