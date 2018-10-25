//
//  KeyViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/16.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class KeyViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.computeServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.listKeyPair(url, token: token).then{ (json) -> Void in
                let keys = json["keypairs"].arrayValue
                KeyService.sharedService.clear()
                var index = 0
                //print(json)
                print(keys.count)
                if keys.count == 0 {
                    let msg = "There is no key pair."
                    let alert = UIAlertController(title: "No Key Pairs", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    
                    for key in keys {
                        
                        let singleKey = Key(json: key)
                        KeyService.sharedService.keys.append(singleKey!)
                        
                        
                        NeCTAREngine.sharedEngine.keypairDetail(singleKey!.name, url: user.computeServiceURL, token: token).then{(json2) -> Void in
                            
                            print(json2)
                            let create = json2["keypair"]["created_at"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ").stringByReplacingOccurrencesOfString("Z", withString: "").componentsSeparatedByString(".")
                            KeyService.sharedService.keys[index].created = create[0]
                            index += 1
                            print("!!!!!!")
                            
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
                        
                        self.tableview.reloadData()
                        self.refreshControl.endRefreshing()
                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)                    }
                    //print(KeyService.sharedService.keys)
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
        refreshControl.addTarget(self, action: #selector(KeyViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        commonInit()
        
        self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return KeyService.sharedService.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if KeyService.sharedService.keys.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("KeyDetail") as! KeyDetailCell
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
            
            let alertController = UIAlertController(title: "Confirm Delete key pair", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction!) -> Void in

            
            if let user = UserService.sharedService.user {
                let url = user.computeServiceURL
                let keyName = KeyService.sharedService.keys[indexPath.row].name
                
                    
                    print("delete")
                    print(keyName)
                    MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    
                    NeCTAREngine.sharedEngine.deleteKeyPair(keyName, url: url, token: user.tokenID).then {
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

        return [delete]
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowKeyDetail" {
            let cell = sender as! KeyDetailCell
            let path = self.tableview.indexPathForCell(cell)
            
            let detailVC =  segue.destinationViewController as! KeyDetailViewController
            detailVC.navigationItem.title = "Key Pair Detail"
            
            detailVC.key = KeyService.sharedService.keys[(path?.row)!]
            detailVC.index = path?.row
            
            
        }
    }
    
}

