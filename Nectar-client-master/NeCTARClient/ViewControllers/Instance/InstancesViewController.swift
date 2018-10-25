//
//  InstancesViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class InstancesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.computeServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listInstances(url, token: token).then{ (json) -> Void in
//                print("HERE IS INSTANCE JSON FILE")
//                print(json)
//                print("THE END!")
                let servers = json["servers"].arrayValue
                InstanceService.sharedService.clear()
                var index1 = 0
                print(json)
                print(servers.count)
                
                if servers.count == 0 {
                    let msg = "There is no instance."
                    let alert = UIAlertController(title: "No Instance", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                for server in servers {
                    
                    let instance = Instance(json: server)
                    InstanceService.sharedService.instances.append(instance!)
                    
                   
                    NeCTAREngine.sharedEngine.queryImage(user.imageServiceURL, token: token, imageID: (instance?.imageId)!).then{(json2) -> Void in
                        let imageName = json2["name"].stringValue
                        
                        InstanceService.sharedService.instances[index1].imageRel = imageName
                        print(imageName)
                        index1 += 1
                        
                        }.error{(err) -> Void in
                            var errorMessage:String = "Action Failed."
                            switch err {
                            case NeCTAREngineError.CommonError(let msg):
                                errorMessage = msg!
                            case NeCTAREngineError.ErrorStatusCode(let code):
                                if code == 401 {
                                    loginRequired()
                                } else {
                                    errorMessage = "Fail to get all the image detail"
                                }
                            default:
                                errorMessage = "Fail to get all the image detail"
                            }
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
                    }
                    
                    for (index, instance) in InstanceService.sharedService.instances.enumerate(){
                    
                    if instance.volumes[0] != "No volumes attached" {
                        
                        InstanceService.sharedService.instances[index].volumesName = ""
                        
                        for one in instance.volumes {
                            NeCTAREngine.sharedEngine.queryVolume(user.tenantID, volumeId: one, url: user.volumeV3ServiceURL, token: token).then{(json2) -> Void in
                                let volumeName = json2["volume"]["name"].stringValue
                                
                                InstanceService.sharedService.instances[index].volumesName += volumeName + ";"
                                }.error{(err) -> Void in
                                    var errorMessage:String = "Action Failed."
                                    switch err {
                                    case NeCTAREngineError.CommonError(let msg):
                                        errorMessage = msg!
                                    case NeCTAREngineError.ErrorStatusCode(let code):
                                        if code == 401 {
                                            loginRequired()
                                        } else {
                                            errorMessage = "Fail to get all the volume detail"
                                        }
                                    default:
                                        errorMessage = "Fail to get all the volume detail"
                                    }
                                    PromptErrorMessage(errorMessage, viewController: self)
                            }
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
                        errorMessage = "Fail to get all instances."
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
        refreshControl.addTarget(self, action: #selector(InstancesViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return InstanceService.sharedService.instances.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if InstanceService.sharedService.instances.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InstanceDetail") as! InstanceDetailCell
            cell.setContent(indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowInstanceDetail" {
            let cell = sender as! InstanceDetailCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! InstanceDetailViewController
            detailVC.navigationItem.title = "Instance Detail"
            detailVC.instance = InstanceService.sharedService.instances[(path?.row)!]
            detailVC.index = path?.row
            
        }
    }

}
