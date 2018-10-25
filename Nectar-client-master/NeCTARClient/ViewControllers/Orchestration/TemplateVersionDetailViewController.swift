//
//  TemplateVersionDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON


// Show details of a resource type according to the associated resource type's index
class TemplateVersionDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    var index: Int!
    var version: String!
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.orchestrationServiceURL
            let token = user.tokenID
            NeCTAREngine.sharedEngine.queryTemplateVersion(url, template_version: self.version, token: token).then{ (json) -> Void in

                let servers = json["template_functions"].arrayValue
                TemplateVersionService.sharedService.clearDetail(self.index)
                if servers.count == 0 {
                    let msg = "There is no function for the template."
                    let alert = UIAlertController(title: "No Function", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let temFunction = TemplateVersionDetail(json: server)
                        TemplateVersionService.sharedService.templateDetails[self.index].append(temFunction!)
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
                            errorMessage = "Fail to get all functions."
                        }
                    default:
                        errorMessage = "Fail to get all functions."
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
        refreshControl.addTarget(self, action: #selector(TemplateVersionDetailViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return TemplateVersionService.sharedService.templateDetails[self.index].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if TemplateVersionService.sharedService.templateDetails[self.index].count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TemplateVersionDetailCell") as! TemplateVersionDetailCell
            cell.setContent(self.index, functionIndex: indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
}



