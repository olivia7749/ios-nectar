//
//  SecurityViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class SecurityViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!

    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.networkServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listSecurityGroups(url, token: token).then{ (json) -> Void in
                let securities = json["security_groups"].arrayValue
                SecurityService.sharedService.clear()
                var remoteid: [String] = []
                print(json)
                print(securities.count)
                if securities.count == 0 {
                    let msg = "There is no security group."
                    let alert = UIAlertController(title: "No Security Groups", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    
                    for securityGroup in securities {
                        
                        let security = Security(json: securityGroup)
                        SecurityService.sharedService.securities.append(security!)

                        
                        for remoteSecurities in (security?.remoteGroupName)! {
                            if remoteSecurities != "-" {
                                
                                if !remoteid.contains(remoteSecurities) {
                                    remoteid.append(remoteSecurities)
                                     print(remoteSecurities)
                                }

                            }
                        }
                        
                        for id in remoteid {
                            
                            NeCTAREngine.sharedEngine.querySecurityGroups(user.networkServiceURL, token: token, securityId: id).then{(json2) -> Void in
                                let remoteSecurityName = json2["security_group"]["name"].stringValue
                                
                                for (index1, i) in SecurityService.sharedService.securities.enumerate() {
                                    for (index2, j) in i.remoteGroupName.enumerate(){
                                        if j == id {
                                            SecurityService.sharedService.securities[index1].remoteGroupName[index2] = remoteSecurityName
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
                                            errorMessage = "Fail to get all the security group detail"
                                        }
                                    default:
                                        errorMessage = "Fail to get all the security group detail"
                                    }
                                    PromptErrorMessage(errorMessage, viewController: self)
                            }
                        }

                        self.tableview.reloadData()
                        self.refreshControl.endRefreshing()
                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                    }
                    print(SecurityService.sharedService.securities)
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
                             errorMessage = "Fail to get all security groups."
                        }
                    default:
                        errorMessage = "Fail to get all security groups."
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
        return SecurityService.sharedService.securities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if SecurityService.sharedService.securities.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SecurityDetail") as! SecurityDetailCell
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
            
            let alertController = UIAlertController(title: "Confirm Delete security group", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction!) -> Void in
            
            if let user = UserService.sharedService.user {
                let url = user.networkServiceURL
                let securityId = SecurityService.sharedService.securities[indexPath.row].id
                
                print(user.owner)
                print(SecurityService.sharedService.securities[indexPath.row].id)
                
                if SecurityService.sharedService.securities[indexPath.row].name != "default" {
                    
                    print("delete")
                    
                    MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.deleteSecurityGroups(securityId, url: url, token: user.tokenID).then {
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
                    
                } else {
                    let msg = "You can not delete this security group."
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
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
                let url = user.networkServiceURL
                let securityId = SecurityService.sharedService.securities[indexPath.row].id
                
                print(user.owner)
                print(SecurityService.sharedService.securities[indexPath.row].id)
                
                if SecurityService.sharedService.securities[indexPath.row].name != "default" {
                    
                    print("edit")
                    
                    let alertController = UIAlertController(title: "Edit Security Group", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addTextFieldWithConfigurationHandler {
                        (textField: UITextField) -> Void in
                        textField.placeholder = "Security Group Name"
                        textField.text = SecurityService.sharedService.securities[indexPath.row].name
                    }
                    
                    alertController.addTextFieldWithConfigurationHandler {
                        (textField: UITextField) -> Void in
                        textField.placeholder = "Description"
                        textField.text = SecurityService.sharedService.securities[indexPath.row].description
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
                                PromptErrorMessage("Security Group name is invalid.", viewController: self)
                            } else {
                                
                                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                            NeCTAREngine.sharedEngine.updateSecurityGroups(securityId, name: name!, description: descritption!, url: url, token: user.tokenID).then{
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
                                        errorMessage = "Fail to edit the security group."
                                    }
                                    PromptErrorMessage(errorMessage, viewController: self)
                            }
                            }
                        }
                    })
                    
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                    
                } else {
                    let msg = "You can not edit this security group."
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }

        }
        edit.backgroundColor = UIColor.orangeColor()
        
        return [delete, edit]
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSecurityDetail" {
            let cell = sender as! SecurityDetailCell
            let path = self.tableview.indexPathForCell(cell)
            
            let detailVC =  segue.destinationViewController as! SecurityDetailViewController
            detailVC.navigationItem.title = "Security Group Detail"
            
            detailVC.security = SecurityService.sharedService.securities[(path?.row)!]
            detailVC.index = path?.row
            
            
        }
    }
    
}

