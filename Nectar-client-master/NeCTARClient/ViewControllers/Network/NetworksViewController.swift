//
//  NetworksViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 22/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

// Show networks in a table view
class NetworksViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.networkServiceURL
            let token = user.tokenID
            
            // Request Openstack to return a json file that contains networks information, and store networks in an array
            NeCTAREngine.sharedEngine.listNetworks(url, token: token).then{ (json) -> Void in
                
                let servers = json["networks"].arrayValue
                NetworkService.sharedService.clear()
                
                print("Network json")
                print(json)
                print(servers.count)
                
                if servers.count == 0 {
                    let msg = "There is no Network."
                    let alert = UIAlertController(title: "No Network", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        var network = Network(json: server)
                        
                        let allowed_external = ["Classic Provider", "auckland", "monash"] // Default networks that cannot be edited
                        if allowed_external.contains(network!.name){
                            network!.subnets = [] // The default networks don't have subnets or ports
                            NetworkService.sharedService.networks.append(network!)
                        } else {
                            if network?.tennantId == user.tenantID{
                                NetworkService.sharedService.networks.append(network!)
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
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get all networks."
                        }
                    default:
                        errorMessage = "Fail to get all networks."
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
        refreshControl.addTarget(self, action: #selector(NetworksViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return NetworkService.sharedService.networks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if NetworkService.sharedService.networks.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NetworkDetailCell") as! NetworkDetailCell
            cell.setContent(indexPath.row)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Jump to the detail interface once the cell is clicked
        if segue.identifier == "ShowNetworkDetail" {
            let cell = sender as! NetworkDetailCell
            let path = self.tableview.indexPathForCell(cell)
            
            let detailVC = segue.destinationViewController as! NetworkDetailViewController
            detailVC.navigationItem.title = "Network Detail"
            detailVC.network = NetworkService.sharedService.networks[(path?.row)!]
            detailVC.index = path?.row
            
            // Jump to another interface to show the subnets of the associated network once the button is clicked
        } else if segue.identifier == "ShowSubnets" {
            let buttonPosition:CGPoint = sender!.convertPoint(CGPoint.zero, toView:self.tableview)
            let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
            let networkId = NetworkService.sharedService.networks[indexPath!.row].id
            let subnetsId = NetworkService.sharedService.networks[indexPath!.row].subnets
            
            
            let detailVC = segue.destinationViewController as! SubnetsViewController
            detailVC.navigationItem.title = "\(NetworkService.sharedService.networks[indexPath!.row].name) Subnets"
            detailVC.networkId = networkId
            detailVC.subnetsId = subnetsId
            
            // Jump to another interface to show the ports of the associated network once the button is clicked
        } else if segue.identifier == "ShowPorts" {
            let buttonPosition:CGPoint = sender!.convertPoint(CGPoint.zero, toView:self.tableview)
            let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
            let networkId = NetworkService.sharedService.networks[indexPath!.row].id
            
            let detailVC = segue.destinationViewController as! PortsViewController
            detailVC.navigationItem.title = "\(NetworkService.sharedService.networks[indexPath!.row].name) Ports"
            detailVC.networkId = networkId
            
        }
    }
    
    
}


