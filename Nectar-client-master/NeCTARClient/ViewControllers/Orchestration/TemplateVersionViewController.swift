//
//  TemplateVersionViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

class TemplateVersionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.orchestrationServiceURL
            let token = user.tokenID
            
            // Request a list of template versions and store them in an array based on the returned json file
            NeCTAREngine.sharedEngine.listTemplateVersion(url, token: token).then{ (json) -> Void in
                
                let servers = json["template_versions"].arrayValue
                TemplateVersionService.sharedService.clear()
                if servers.count == 0 {
                    let msg = "There is no template service."
                    let alert = UIAlertController(title: "No Template Service", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let template = TemplateVersion(json: server)
                        TemplateVersionService.sharedService.templateVersions.append(template!)
                        TemplateVersionService.sharedService.templateDetails.append([])
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
                            errorMessage = "Fail to get all template versions."
                        }
                    default:
                        errorMessage = "Fail to get all template versions."
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
        refreshControl.addTarget(self, action: #selector(TemplateVersionViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        commonInit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TemplateVersionService.sharedService.templateVersions.count
    }
    
    // Load all resources in a tableView, and store details of each reqource type into a single cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if TemplateVersionService.sharedService.templateVersions.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TemplateVersionCell") as! TemplateVersionCell
            cell.setContent(indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func statusChanged() {
        self.tableview.reloadData()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Jump to the detail interface once the cell is clicked
        if segue.identifier == "ShowTemplateVersionDetail" {
            let cell = sender as! TemplateVersionCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! TemplateVersionDetailViewController
            detailVC.navigationItem.title = "Template Version Details"
            detailVC.version = TemplateVersionService.sharedService.templateVersions[(path?.row)!].version
            detailVC.index = path?.row
            
            
        }
    }
    
}


