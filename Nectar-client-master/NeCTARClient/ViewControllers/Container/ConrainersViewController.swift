//
//  ConrainersViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

// Show containers in a table view
class ContainersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.objectStorageServiceURL
            let token = user.tokenID
            print("The object storage service url is \(url)")
            
            // Request Openstack to return a json file that contains containers information, and store them in an array
            NeCTAREngine.sharedEngine.listContainers(url, token: token).then{ (json) -> Void in
                let servers = json[].arrayValue
                ContainerService.sharedService.clear()
                
                print("Container json")
                print(json)
                print(servers.count)
                
                if servers.count == 0 {
                    let msg = "There is no container."
                    let alert = UIAlertController(title: "No Container", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let container = Container(json: server)
                        
                        ContainerService.sharedService.containers.append(container!)
                        
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
                            errorMessage = "Fail to get all containers."
                        }
                    default:
                        errorMessage = "Fail to get all containers."
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
        refreshControl.addTarget(self, action: #selector(ContainersViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return ContainerService.sharedService.containers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if ContainerService.sharedService.containers.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContainerDetailCell") as! ContainerDetailCell
            cell.setContent(indexPath.row)
            cell.deleteButton.addTarget(self, action:#selector(ContainersViewController.deleteContainer),forControlEvents:.TouchUpInside)
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    // Request the Openstack to delete the container
    func deleteContainer(sender: UIButton){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let buttonPosition:CGPoint = sender.convertPoint(CGPoint.zero, toView:self.tableview)
        let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
        let delName = ContainerService.sharedService.containers[indexPath!.row].name
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteContainer(delName, url: user.objectStorageServiceURL, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("ContainerDeleted", obj: "deleted")
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
                            errorMessage = "Cannot delete a container that is not empty." // Users need to delete all objects in a container before it can be deleted
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Jump to the interface that show objects of the container once the cell is clicked
        if segue.identifier == "ShowContainerDetail" {
            let cell = sender as! ContainerDetailCell
            let path = self.tableview.indexPathForCell(cell)
            
            let detailVC = segue.destinationViewController as! ContainerDetailViewController
            detailVC.navigationItem.title = "Objects"
            detailVC.container = ContainerService.sharedService.containers[(path?.row)!]
            detailVC.index = path?.row
            
            
        }
    }
    
}

