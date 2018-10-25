//
//  BackupsViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

class BackupsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var instanceId: String = ""
    var instanceName: String = ""
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.databaseServiceURL
            let token = user.tokenID
            BackupService.sharedService.clear()
            
            // Request a list of backups and store them in an array based on the returned json file
            NeCTAREngine.sharedEngine.listBackups(url, instanceId: self.instanceId, token: token).then{ (json) -> Void in
                let servers = json["backups"].arrayValue
                BackupService.sharedService.clear()
                if servers.count == 0 {
                    let msg = "There is no backup for this instance."
                    let alert = UIAlertController(title: "No backup", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let backup = Backup(json: server)
                        BackupService.sharedService.backups.append(backup!)
                    }
                }
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.tableview.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
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
                            errorMessage = "Fail to get backups."
                        }
                    default:
                        errorMessage = "Fail to get the backups."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            //            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            //            dispatch_after(delayTime, dispatch_get_main_queue()) {
            //                self.tableview.reloadData()
            //                self.refreshControl.endRefreshing()
            //                MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
            //            }
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        let btn=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action:#selector(BackupsViewController.createBackup),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(BackupsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return BackupService.sharedService.backups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if BackupService.sharedService.backups.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BackupDetailCell") as! BackupDetailCell
            cell.setContent(indexPath.row)
            cell.deleteButton.addTarget(self, action:#selector(BackupsViewController.deleteBackup),forControlEvents:.TouchUpInside)
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    func createBackup(sender: UIButton){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("AddBackupsViewController") as! AddBackupsViewController
            
            editVc.instanceId = self.instanceId
            editVc.instanceName = self.instanceName
            
            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
    func deleteBackup(sender: UIButton){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let buttonPosition:CGPoint = sender.convertPoint(CGPoint.zero, toView:self.tableview)
        let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
        let backupId = BackupService.sharedService.backups[(indexPath?.row)!].id
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteBackup(user.databaseServiceURL, backupId: backupId, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("BackupDeleted", obj: "deleted")
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
                            errorMessage = "Action failed."
                            //errorMessage = "Cannot delete a container that is not empty."
                        }
                    default:
                        errorMessage = "Action failed."
                        //errorMessage = "Cannot delete a container that is not empty."
                    }
                    PromptErrorMessage(errorMessage, viewController: self, callback: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    })
            }
        }
        
    }
    
}
