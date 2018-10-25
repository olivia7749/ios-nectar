//
//  SecurityDetailViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class SecurityDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var security: Security?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()

    @IBOutlet var tableview: UITableView!
    
    var addSecurityGroupRuleViewController: AddSecurityGroupRuleViewController!
    var centerOfBeginning: CGPoint!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //panGesture.addTarget(self, action: #selector(pan(_:)))
        //self.view.addGestureRecognizer(panGesture)
        
        hudParentView = self.view
        
        self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add,  target: self, action: #selector(addTapped))
        
        self.navigationItem.rightBarButtonItems=[rightAddBarButtonItem]

    }
    
    func addTapped(){
        
        self.addSecurityGroupRuleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddSecurityGroupRuleViewController") as! AddSecurityGroupRuleViewController
        //self.navigationItem.title = "New Rule"
        //self.navigationItem.rightBarButtonItem = nil
        
        self.navigationController?.pushViewController(self.addSecurityGroupRuleViewController, animated: true)
        
        addSecurityGroupRuleViewController.securityId = SecurityService.sharedService.securities[self.index!].id
        
    }


    func returnToRootView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SecurityService.sharedService.securities[self.index!].direction.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if SecurityService.sharedService.securities[self.index!].direction.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SecurityDetailDetail") as! SecurityDetailDetailCell
            cell.setContent(SecurityService.sharedService.securities[self.index!], index: indexPath.row)
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
            
            let alertController = UIAlertController(title: "Confirm Delete security group rule", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction!) -> Void in

            
            if let user = UserService.sharedService.user {
                let url = user.networkServiceURL
                let ruleId = SecurityService.sharedService.securities[self.index!].ruleId[indexPath.row]
                    
                    print("delete")
                    MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    
                    NeCTAREngine.sharedEngine.deleteSecurityGroupsRule(ruleId, url: url, token: user.tokenID).then {
                        (json) -> Void in
                        print("delete")
                        print (json)
                        let msg = "Refresh."
                        let alert = UIAlertController(title: "Delete Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        SecurityService.sharedService.securities[self.index!].direction.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].ethertype.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].ipProtocol.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].portRange.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].remoteGroupId.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].remoteGroupName.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].remoteIpPrefix.removeAtIndex(indexPath.row)
                        SecurityService.sharedService.securities[self.index!].ruleId.removeAtIndex(indexPath.row)
                        
                        self.tableview.reloadData()

                        
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
        
        return [delete]
    }
    

}
