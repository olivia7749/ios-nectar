//
//  VolumeSnapshotViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class VolumeSnapshotViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.volumeV3ServiceURL
            let token = user.tokenID
            var index = 0
            NeCTAREngine.sharedEngine.listVolumeSnapshot(user.tenantID,url: url, token: token).then{ (json) -> Void in
                let snapshots = json["snapshots"].arrayValue
                VolumeSnapshotService.sharedService.clear()
                print(json)
                print(snapshots.count)
                if snapshots.count == 0 {
                    let msg = "There is no volume snapshot."
                    let alert = UIAlertController(title: "No Volume Snapshot", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    
                    for ones in snapshots {
                        
                        let snapshot = VolumeSnapshot(json: ones)
                        VolumeSnapshotService.sharedService.snapshots.append(snapshot!)
                        
                        //print(VolumeSnapshotService.sharedService.snapshots[index].volumeId)
                        
                        if !VolumeSnapshotService.sharedService.snapshots[index].volumeId.isEmpty {
                            
                            VolumeSnapshotService.sharedService.snapshots[index].volumeName = ""
                            VolumeSnapshotService.sharedService.snapshots[index].volumeZone = ""
                            
                            NeCTAREngine.sharedEngine.queryVolume(user.tenantID, volumeId: (snapshot?.volumeId)! ,url: user.volumeV3ServiceURL, token: token).then{(json2) -> Void in
                                let volumeName = json2["volume"]["name"].stringValue
                                VolumeSnapshotService.sharedService.snapshots[index].volumeName = volumeName
                                let volumeZone = json2["volume"]["availability_zone"].stringValue
                                VolumeSnapshotService.sharedService.snapshots[index].volumeZone = volumeZone
                                index += 1
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
                            errorMessage = "Fail to get all volume snapshot."
                        }
                    default:
                        errorMessage = "Fail to get all volume snapshot."
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
        refreshControl.addTarget(self, action: #selector(SecurityViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        commonInit()
        
        self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VolumeSnapshotService.sharedService.snapshots.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if VolumeSnapshotService.sharedService.snapshots.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("VolumeSnapshotDetail") as! VolumeSnapshotDetailCell
            cell.setContent(indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") {
            action, index in
            
            let alertController = UIAlertController(title: "Confirm Delete volume snapshot", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction!) -> Void in
            
            if let user = UserService.sharedService.user {
                let url = user.volumeV3ServiceURL
                    print("delete")
                
                    let snapshotId = VolumeSnapshotService.sharedService.snapshots[indexPath.row].id
                
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                
                NeCTAREngine.sharedEngine.deleteVolumeSnapshot(user.tenantID, snapshotId: snapshotId, url: url, token: user.tokenID).then {
                        (json) -> Void in
                        print("delete")
                        print (json)
                        let msg = "Please refresh."
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
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
            }
                
            })
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        delete.backgroundColor = UIColor.redColor()
        
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") {
            action, index in
            
            if let user = UserService.sharedService.user {
                let url = user.volumeV3ServiceURL
                let snapshotId = VolumeSnapshotService.sharedService.snapshots[indexPath.row].id
                    
                    print("edit")
                    
                    let alertController = UIAlertController(title: "Edit Snapshot", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addTextFieldWithConfigurationHandler {
                        (textField: UITextField) -> Void in
                        textField.placeholder = "Snapshot Name"
                        textField.text = VolumeSnapshotService.sharedService.snapshots[indexPath.row].name
                    }
                    
                    alertController.addTextFieldWithConfigurationHandler {
                        (textField: UITextField) -> Void in
                        textField.placeholder = "Description"
                        textField.text = VolumeSnapshotService.sharedService.snapshots[indexPath.row].description
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                        (action: UIAlertAction!) -> Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    })
                    let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
                        (action: UIAlertAction!) -> Void in
                        let nameField = (alertController.textFields?.first)! as UITextField
                        let descritptionField = (alertController.textFields?.last)! as UITextField
                        let name = nameField.text
                        let descritption = descritptionField.text
                        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                        
                        if let user = UserService.sharedService.user{
                            
                            if name!.stringByTrimmingCharactersInSet(whitespace).isEmpty {
                                PromptErrorMessage("Snapshot name is invalid.", viewController: self)
                            } else {
                                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                                NeCTAREngine.sharedEngine.updateVolumeSnapshot(user.tenantID, snapshotId: snapshotId, name: name!, description: descritption!, url: url, token: user.tokenID).then{
                                    (json) -> Void in
                                    print("edit security")
                                    let msg = "Please refresh."
                                    let alert = UIAlertController(title: "Edit Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                                        self.dismissViewControllerAnimated(false, completion: nil)
                                    }))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    
                                    
                                    }.always{
                                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                                    }.error {
                                        (err) -> Void in
                                        print(err)
                                        var errorMessage:String = "Action Failed."
                                        switch err {
                                        case NeCTAREngineError.CommonError(let msg):
                                            errorMessage = msg!
                                        default:
                                            errorMessage = "Fail to edit the snapshot."
                                        }
                                        PromptErrorMessage(errorMessage, viewController: self)
                                }
                            }
                        }
                    })
                    
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

            }
            
        }
        edit.backgroundColor = UIColor.orangeColor()
        
        return [delete, edit]
        
    }
    
    
    
}
