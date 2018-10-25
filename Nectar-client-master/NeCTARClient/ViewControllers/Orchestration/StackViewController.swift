//
//  StackViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

class StackViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.orchestrationServiceURL
            let token = user.tokenID
            
            // Request a list of stacks and store them in an array based on the returned json file
            NeCTAREngine.sharedEngine.listStacks(url, token: token).then{ (json) -> Void in
                let servers = json["stacks"].arrayValue
                StackService.sharedService.clear()
                
                if servers.count == 0 {
                    let msg = "There is no stack."
                    let alert = UIAlertController(title: "No Stack", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    var aindex = 0
                    for server in servers {
                        let stack = Stack(json: server)
                        StackService.sharedService.stacks.append(stack!)
                        
                        NeCTAREngine.sharedEngine.queryStack(url, stackName: stack!.name, stackId: stack!.id, token: token).then{ (json2) -> Void in
                            
                            let newDescrip = json2["stack"]["description"].stringValue
                            StackService.sharedService.stacks[aindex].descrip = newDescrip
                            let rollbackValue = json2["stack"]["disable_rollback"].stringValue
                            if rollbackValue == "true" {
                                StackService.sharedService.stacks[aindex].rollback = "Disabled"
                            } else {
                                StackService.sharedService.stacks[aindex].rollback = "Enabled"
                            }
                            aindex += 1
                            }.error{(err) -> Void in
                                var errorMessage:String = "Query root status action Failed."
                                switch err {
                                case NeCTAREngineError.CommonError(let msg):
                                    errorMessage = msg!
                                    
                                case NeCTAREngineError.ErrorStatusCode(let code):
                                    if code == 401 {
                                        loginRequired()
                                    } else {
                                        errorMessage = "Fail to get all roots."
                                    }
                                default:
                                    errorMessage = "Fail to get all roots."
                                }
                                PromptErrorMessage(errorMessage, viewController: self)
                        }
                    }
                    
                    // Refresh the interface in 2 seconds
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
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
                            errorMessage = "Fail to get all stacks."
                        }
                    default:
                        errorMessage = "Fail to get all stacks."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Stacks"
        commonInit()
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(StackViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        
    }
    
    func statusChanged() {
        self.tableview.reloadData()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StackService.sharedService.stacks.count
    }
    
    // Load all resources in a tableView, and store details of each reqource type into a single cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if StackService.sharedService.stacks.count != 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("StackDetailCell") as! StackDetailCell
            cell.setContent(indexPath.row)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Jump to the detail interface once the cell is clicked
        if segue.identifier == "ShowStackDetail" {
            let cell = sender as! StackDetailCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! StacksDetailViewController
            detailVC.navigationItem.title = "Stack Detail"
            detailVC.index = path?.row
        }
        
        
    }
}

