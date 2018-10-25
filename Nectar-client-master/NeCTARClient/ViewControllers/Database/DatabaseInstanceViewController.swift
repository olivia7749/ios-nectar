//
//  atabaseInstanceViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

// Show database instances in a tableview
class DatabaseInstanceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.databaseServiceURL
            let token = user.tokenID
            let tenantId = user.tenantID
            
            // Request a list of database instances and store them in an array based on the returned json file
            NeCTAREngine.sharedEngine.listDatabaseInstances(url, tenantId: tenantId, token: token).then{ (json) -> Void in
                
                let servers = json["instances"].arrayValue
                DatabaseInstanceService.sharedService.clear()
                
                if servers.count == 0 {
                    let msg = "There is no database instance."
                    let alert = UIAlertController(title: "No Database Instance", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    
                    for server in servers {
                        
                        let serverId = server["id"].stringValue
                        
                        // Request the detail of a database instance and store it
                        NeCTAREngine.sharedEngine.queryDatabaseInstance(url, token: token, tenantId: tenantId, instanceId: serverId).then{ (json1) -> Void in
                            
                            let instance = DatabaseInstance(json: json1)
                            DatabaseInstanceService.sharedService.databaseInstances.append(instance!)
                            
                            }.error{(err) -> Void in
                                var errorMessage:String = "Action Failed."
                                switch err {
                                case NeCTAREngineError.CommonError(let msg):
                                    errorMessage = msg!
                                    
                                case NeCTAREngineError.ErrorStatusCode(let code):
                                    if code == 401 {
                                        loginRequired()
                                    } else {
                                        errorMessage = "Fail to get instance details."
                                    }
                                default:
                                    errorMessage = "Fail to get instance details."
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
                            errorMessage = "Fail to get all instances."
                        }
                    default:
                        errorMessage = "Fail to get all instance."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            
        }
        
        if let user = UserService.sharedService.user{
            let token = user.tokenID
            
            // Reuest for the amount of available volumes which will be used in creating a new instance or edit its volume
            NeCTAREngine.sharedEngine.getVolumeLimit(user.volumeV3ServiceURL, projectId: user.tenantID ,token: token).then{ (json) -> Void in
                let absolute = json["limits"]["absolute"]
                let usedVolumeInGB = absolute["totalGigabytesUsed"].doubleValue
                let unusedVolumeInGB = absolute["maxTotalVolumeGigabytes"].doubleValue - usedVolumeInGB
                let restVolume:Int = Int(floor(unusedVolumeInGB))
                var volumeSizeP: [String] = []
                var i: Int = 0
                while i < restVolume {
                    volumeSizeP.append(String(i))
                    i += 1
                }
                
                DatabaseInstanceService.sharedService.unusedVolumeSize = volumeSizeP
                MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get overview information1."
                        }
                    default:
                        errorMessage = "Fail to get overview information2."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Database Instances"
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        commonInit()
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(DatabaseInstanceViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        
        // Apply searchRoot() after instances being loaded
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.searchRoot()
        }
        
        // Apply searchFlavor() after searchRoot() being loaded
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.searchFlavor()
        }
    }
    
    // Determine whether root has been enabled
    func searchRoot() {
        let user = UserService.sharedService.user
        let url = user?.databaseServiceURL
        let token = user?.tokenID
        let tenantId = user?.tenantID
        var aindex : Int = 0
        for instance in DatabaseInstanceService.sharedService.databaseInstances {
            if instance.status == "ACTIVE" {
                NeCTAREngine.sharedEngine.queryDatabaseRoot(url!, token: token!, tenantId: tenantId!, instanceId: instance.id).then{ (json2) -> Void in
                    let rootValue = json2["rootEnabled"].stringValue
                    if rootValue == "true" {
                        let rootEnabled = "Yes"
                        DatabaseInstanceService.sharedService.databaseInstances[aindex].rootEnabled = rootEnabled

                    } else if rootValue == "false" {
                        let rootEnabled = "No"
                        DatabaseInstanceService.sharedService.databaseInstances[aindex].rootEnabled = rootEnabled
                    }
                    aindex += 1
                    
                    if aindex == DatabaseInstanceService.sharedService.databaseInstances.count {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    }.error{(err) -> Void in
                        var errorMessage:String = "Query root status action Failed."
                        switch err {
                        case NeCTAREngineError.CommonError(let msg):
                            errorMessage = msg!
                            
                        case NeCTAREngineError.ErrorStatusCode(let code):
                            if code == 401 {
                                loginRequired()
                            } else {
                                errorMessage = "Fail to get all roots.\(err)"
                            }
                        default:
                            errorMessage = "Fail to get all roots."
                        }
                        PromptErrorMessage(errorMessage, viewController: self)
                        
                }
                
            } else {
                DatabaseInstanceService.sharedService.databaseInstances[aindex].rootEnabled = "Unable to obtain information on root user"
                aindex += 1
                if aindex == DatabaseInstanceService.sharedService.databaseInstances.count {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
    }
    
    // Get details of a flavor
    func searchFlavor() {
        let user = UserService.sharedService.user
        let url = user?.databaseServiceURL
        let token = user?.tokenID
        let tenantId = user?.tenantID
        var index : Int = 0
        for instance in DatabaseInstanceService.sharedService.databaseInstances {
            
            NeCTAREngine.sharedEngine.queryDatabaseflavor(url!, token: token!, tenantId: tenantId!, flavorId: instance.flavorId).then{ (json3) -> Void in
                
                let flavorName = json3["flavor"]["name"].stringValue
                DatabaseInstanceService.sharedService.databaseInstances[index].flavorName = flavorName
                index += 1
                }.error{(err) -> Void in
                    var errorMessage:String = "Query flavor action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get all flavors."
                        }
                    default:
                        errorMessage = "Fail to get all flavors."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
                    
            }
        }
    }
    
    
    func statusChanged() {
        self.tableview.reloadData()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseInstanceService.sharedService.databaseInstances.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if DatabaseInstanceService.sharedService.databaseInstances.count != 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DatabaseInstanceDetailCell") as! DatabaseInstanceDetailCell
            cell.setContent(indexPath.row)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Jump to the detail interface once the cell is clicked
        if segue.identifier == "ShowDatabaseInstanceDetail" {
            let cell = sender as! DatabaseInstanceDetailCell
            let path = self.tableview.indexPathForCell(cell)
            
            let detailVC = segue.destinationViewController as! DatabaseInstanceDetailViewController
            detailVC.navigationItem.title = "Instance Detail"
            detailVC.databaseInstance = DatabaseInstanceService.sharedService.databaseInstances[(path?.row)!]
            detailVC.index = path?.row
        } else if segue.identifier == "ShowBackups" {
            
            // Jump to the backup interface once the button is clicked
            let buttonPosition:CGPoint = sender!.convertPoint(CGPoint.zero, toView:self.tableview)
            let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
            let instanceId = DatabaseInstanceService.sharedService.databaseInstances[indexPath!.row].id
            let instanceName = DatabaseInstanceService.sharedService.databaseInstances[indexPath!.row].name
            
            
            let detailVC = segue.destinationViewController as! BackupsViewController
            detailVC.navigationItem.title = "\(DatabaseInstanceService.sharedService.databaseInstances[indexPath!.row].name) Backups"
            detailVC.instanceId = instanceId
            detailVC.instanceName = instanceName
            
        }
    }
    
    
}
