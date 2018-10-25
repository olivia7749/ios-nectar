//
//  VolumeViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/29.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class VolumeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var tableview: UITableView!
    
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    var pickerSet: [String] = []
    var serverId: [String] = []
    var serverZone: [String] = []
    
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            
            pickerSet = []
            serverId = []
            
            NeCTAREngine.sharedEngine.listInstances(user.computeServiceURL, token: user.tokenID).then{ (json) -> Void in
                let servers = json["servers"].arrayValue
                InstanceService.sharedService.clear()
                for server in servers {
                    
                    let instance = Instance(json: server)
                    InstanceService.sharedService.instances.append(instance!)
                    self.pickerSet.append((instance?.name)!)
                    self.serverId.append((instance?.id)!)
                    self.serverZone.append((instance?.zone)!)
                    
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
            
            
            let url = user.volumeV3ServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listVolume(user.tenantID, url: url, token: token).then{ (json) -> Void in
                let volumes = json["volumes"].arrayValue
                VolumeService.sharedService.clear()
                print(json)
                print(volumes.count)
                if volumes.count == 0 {
                    let msg = "There is no volume."
                    let alert = UIAlertController(title: "No Volume", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    
                    for oneV in volumes {
                        
                        let volume = Volume(json: oneV)
                        VolumeService.sharedService.volumes.append(volume!)
                    }
                    
                    for (index, one) in  VolumeService.sharedService.volumes.enumerate(){
                        if one.attachToId != "-" {
                                
                                NeCTAREngine.sharedEngine.queryInstances(one.attachToId, url: user.computeServiceURL, token: token).then{(json2) -> Void in
                                    let attachName = json2["server"]["name"].stringValue
                                    print(index)
                                    VolumeService.sharedService.volumes[index].attachToName = attachName
                                    //index += 1
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
                        
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            //index += 1
                            //print(index)
                            
                            self.tableview.reloadData()
                            self.refreshControl.endRefreshing()
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                            print(self.pickerSet)
                        }
                    }
                    //print(VolumeService.sharedService.volumes)
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
                            errorMessage = "Fail to get all volumes."
                        }
                    default:
                        errorMessage = "Fail to get all volumes."
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
        return VolumeService.sharedService.volumes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if VolumeService.sharedService.volumes.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("VolumeDetail") as! VolumeDetailCell
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
        
        let action = UITableViewRowAction(style: .Normal, title: "Actions") {
            action, index in
                
                let alertController = UIAlertController(title: "Actions", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {action in self.deleteVolume(indexPath.row)})
                let attachAction = UIAlertAction(title: "Attach To", style: UIAlertActionStyle.Default, handler: {action in self.attach(indexPath.row)})
                let detachAction = UIAlertAction(title: "Detach", style: UIAlertActionStyle.Default, handler: {action in self.detach(indexPath.row)})
                let snapshotAction = UIAlertAction(title: "Create Snapshot", style: UIAlertActionStyle.Default, handler: {action in self.createSnapshot(indexPath.row)})
                let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default, handler: {action in self.edit(indexPath.row)})
                let extendAction = UIAlertAction(title: "Extend", style: UIAlertActionStyle.Default, handler: {action in self.extend(indexPath.row)})
                alertController.addAction(cancelAction)
            if VolumeService.sharedService.volumes[indexPath.row].status == "in-use" {
                alertController.addAction(detachAction)
                alertController.addAction(snapshotAction)
                alertController.addAction(editAction)
            } else if VolumeService.sharedService.volumes[indexPath.row].status == "available" {
                alertController.addAction(deleteAction)
                alertController.addAction(attachAction)
                alertController.addAction(extendAction)
                alertController.addAction(snapshotAction)
                alertController.addAction(editAction)
            }
            
                self.presentViewController(alertController, animated: true, completion: nil)
            
            
            
        }
        action.backgroundColor = UIColor.blueColor()
        
        return [action]
        
    }
    
    func deleteVolume(index: Int){
        
        let alertController = UIAlertController(title: "Confirm Delete volume", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
            (action: UIAlertAction!) -> Void in
            if let user = UserService.sharedService.user {
                
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                
                let url = user.volumeV3ServiceURL
                let volumeId = VolumeService.sharedService.volumes[index].id
                
                print(user.owner)
                
                
                print("delete")
                
                NeCTAREngine.sharedEngine.deleteVolume(user.tenantID, volumeId: volumeId, url: url, token: user.tokenID).then {
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerSet.count }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerSet[row] }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.pickerSet[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
 
        return pickerLabel
    }
    
    
    func doSomethingWithValue(index: Int, serverId: String, serverZone: String) {
        print(serverId)
        print(serverZone)
        
        if serverZone != VolumeService.sharedService.volumes[index].zone {
            
            PromptErrorMessage("Unable to attach volume. Inconsistent Availability Zone.", viewController: self)
            
        } else {
            
            if let user = UserService.sharedService.user{
                
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                
                NeCTAREngine.sharedEngine.attachVolume(VolumeService.sharedService.volumes[index].id, instanceId: serverId, url: user.computeServiceURL, token: user.tokenID).then {
                    (json) -> Void in
                    print("delete")
                    print (json)
                    let msg = "Please refresh."
                    let alert = UIAlertController(title: "Attach Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
            
        }
        
    }
    
    func attach(index: Int){
        
        if pickerSet.isEmpty {
            let msg = "There is no instance."
            let alert = UIAlertController(title: "No Instance", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let message = "\n\n\n\n\n\n\n\n"
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.modalInPopover = true
            
            let attributedString = NSAttributedString(string: "Please select a instance", attributes: [
                NSFontAttributeName : UIFont.systemFontOfSize(20), //your font here,
                NSForegroundColorAttributeName : UIColor(red:0.29, green:0.45, blue:0.74, alpha:1.0) ])
            alert.setValue(attributedString, forKey: "attributedTitle")
            
            //Create a frame (placeholder/wrapper) for the picker and then create the picker
            let pickerFrame: CGRect = CGRectMake(35, 52, 200, 140) // CGRectMake(left, top, width, height) - left and top are like margins
            let picker: UIPickerView = UIPickerView(frame: pickerFrame)
            //picker.backgroundColor = UIColor(red:0.29, green:0.45, blue:0.74, alpha:1.0)
            
            //set the pickers datasource and delegate
            picker.delegate = self
            picker.dataSource = self
            
            //Add the picker to the alert controller
            alert.view.addSubview(picker)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "Attach", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in self.doSomethingWithValue(index, serverId: self.serverId[picker.selectedRowInComponent(0)], serverZone: self.serverZone[picker.selectedRowInComponent(0)]) })
            alert.addAction(okAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    
    func detach(index: Int){
        
        let alertController = UIAlertController(title: "Confirm Detach volume", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        let okAction = UIAlertAction(title: "Detach", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
        
        if let user = UserService.sharedService.user {
            let url = user.computeServiceURL
            let volumeId = VolumeService.sharedService.volumes[index].id
            
            MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
            
            print("detach")
            
            
            NeCTAREngine.sharedEngine.deleteAttachment(VolumeService.sharedService.volumes[index].attachToId, volumeId: volumeId, url: url, token: user.tokenID).then {
                (json) -> Void in
                print("detach")
                print (json)
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Detach Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    func createSnapshot(index: Int){
        let alertController = UIAlertController(title: "Create Volume Snapshot", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = "Snapshot Name"
        }
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = "Description"
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
                    NeCTAREngine.sharedEngine.createVolumeSnapshot(VolumeService.sharedService.volumes[index].id, projectId: user.tenantID, description: descritption!, url: user.volumeV3ServiceURL, name: name!, token: user.tokenID).then{
                        (json) -> Void in
                        print("create snapshot")
                        let msg = "Please refresh."
                        let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
                                errorMessage = "Fail to create the snapshot."
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
    
    func edit(index: Int){
            
                print("edit")
                
                let alertController = UIAlertController(title: "Edit Volume", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addTextFieldWithConfigurationHandler {
                    (textField: UITextField) -> Void in
                    textField.placeholder = "Volume Name"
                    textField.text = VolumeService.sharedService.volumes[index].name
                }
                
                alertController.addTextFieldWithConfigurationHandler {
                    (textField: UITextField) -> Void in
                    textField.placeholder = "Description"
                    textField.text = VolumeService.sharedService.volumes[index].description
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
                            PromptErrorMessage("Volume name is invalid.", viewController: self)
                        } else {
                            
                             MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                            NeCTAREngine.sharedEngine.updateVolume(user.tenantID, volumeId: VolumeService.sharedService.volumes[index].id, name: name!, description: descritption!, url: user.volumeV3ServiceURL, token: user.tokenID).then{
                                (json) -> Void in
                                print("edit volume")
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
                                        errorMessage = "Fail to edit the volume."
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
    
    func extend(index: Int){
            
            print("extend")
            
            let alertController = UIAlertController(title: "Extend Volume", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler {
                (textField: UITextField) -> Void in
                textField.placeholder = "Volume Name"
                textField.text = VolumeService.sharedService.volumes[index].name
                textField.enabled = false
            }
            
            alertController.addTextFieldWithConfigurationHandler {
                (textField: UITextField) -> Void in
                textField.placeholder = "Current Size (GB)"
                textField.text = VolumeService.sharedService.volumes[index].size
                textField.enabled = false
            }
            alertController.addTextFieldWithConfigurationHandler {
                (textField: UITextField) -> Void in
                textField.placeholder = "New Size (GB)"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                let sizeField = (alertController.textFields?.last)! as UITextField
                let size = sizeField.text
                let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                
                
                
                if let user = UserService.sharedService.user{
                    
                    if size!.stringByTrimmingCharactersInSet(whitespace).isEmpty {
                        PromptErrorMessage("New size is invalid.", viewController: self)
                    } else {
                        
                        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                        
                        NeCTAREngine.sharedEngine.extendVolume(user.tenantID, volumeId: VolumeService.sharedService.volumes[index].id, size: Int(size!)!, url: user.volumeV3ServiceURL, token: user.tokenID).then{
                            (json) -> Void in
                            print("extend volume")
                            let msg = "Please refresh."
                            let alert = UIAlertController(title: "Extend Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
                                    errorMessage = "Fail to extend the volume."
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVolumeDetail" {
            let cell = sender as! VolumeDetailCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! VolumeDetailViewController
            detailVC.navigationItem.title = "Volume Detail"
            detailVC.volume = VolumeService.sharedService.volumes[(path?.row)!]
            detailVC.index = path?.row
            
        }
    }
    
    
    
}
