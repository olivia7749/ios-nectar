//
//  RoutersViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 14/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

// Show routers in a table view
class RoutersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.networkServiceURL
            let token = user.tokenID
            print("The router url is \(url)")
            
            // Request Openstack to return a json file that contains routers information, and store them in an array
            NeCTAREngine.sharedEngine.listRouters(url, token: token).then{ (json) -> Void in
                let servers = json["routers"].arrayValue
                RouterService.sharedService.clear()
                var index1 = 0
                print("Router json")
                print(json)
                print(servers.count)
                
                if servers.count == 0 {
                    let msg = "There is no router."
                    let alert = UIAlertController(title: "No Router", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let router = Router(json: server)
                        RouterService.sharedService.routers.append(router!)
                        if ((router?.networkID) != "-") {
                            NeCTAREngine.sharedEngine.queryNetwork(user.networkServiceURL, token: token, networkID: (router?.networkID)!).then{(json2) -> Void in
                                let externalNetworkName = json2["network"]["name"].stringValue
                                
                                
                                RouterService.sharedService.routers[index1].gatewayName = externalNetworkName
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
                                            errorMessage = "Fail to get all the external network detail"
                                    }
                                    default:
                                        errorMessage = "Fail to get all the external network detail"
                                    }
                                    PromptErrorMessage(errorMessage, viewController: self)
                            }
                        } else {
                            RouterService.sharedService.routers[index1].gatewayName = "-"
                            
                            index1 += 1
                        }
                        //index1 += 1
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
                            errorMessage = "Fail to get all routers1."
                        }
                    default:
                        errorMessage = "Fail to get all routers2."
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
        refreshControl.addTarget(self, action: #selector(RoutersViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return RouterService.sharedService.routers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if RouterService.sharedService.routers.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RouterDetail") as! RouterDetailCell
            cell.setContent(indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Jump to the interface that show details of the router once the cell is clicked
        if segue.identifier == "ShowRouterDetail" {
            let cell = sender as! RouterDetailCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! RouterDetailViewController
            detailVC.navigationItem.title = "Router Detail"
            detailVC.router = RouterService.sharedService.routers[(path?.row)!]
            detailVC.index = path?.row
            
        }
    }
    
}
