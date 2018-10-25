//
//  ContainerDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 21/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

// Show all the objects of a container
class ContainerDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var container: Container?
    var index: Int?
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    var hudParentView = UIView()
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.objectStorageServiceURL
            let token = user.tokenID
            let containerName = ContainerService.sharedService.containers[self.index!].name
            
            // Request Openstack to return a json file that contains objects of the container, and store them in an array
            NeCTAREngine.sharedEngine.listObjects(url,containerName: containerName, token: token).then{ (json) -> Void in
                
                let servers = json[].arrayValue
                ObjectService.sharedService.clear()
                
                print("Object json")
                print(json)
                print(servers.count)
                
                if servers.count == 0 {
                    let msg = "There is no Object in this container."
                    let alert = UIAlertController(title: "No Object", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
                } else {
                    for server in servers {
                        
                        let object = Object(json: server)
                        
                        ObjectService.sharedService.objects.append(object!)
                        
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
                            errorMessage = "Fail to get all objects."
                        }
                    default:
                        errorMessage = "Fail to get all objects."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        let btn=UIButton(frame: CGRectMake(0, 0, 80, 30))
        btn.setTitle("Actions", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn.addTarget(self, action:#selector(ContainerDetailViewController.containerAction),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ContainerDetailViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        return ObjectService.sharedService.objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if ObjectService.sharedService.objects.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ObjectDetailCell") as! ObjectDetailCell
            cell.setContent(indexPath.row)
            cell.deleteButton.addTarget(self, action:#selector(ContainerDetailViewController.deleteObject),forControlEvents:.TouchUpInside)
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    
    // Request the Openstack to delete the object
    func deleteObject(sender: UIButton){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let buttonPosition:CGPoint = sender.convertPoint(CGPoint.zero, toView:self.tableview)
        let indexPath = self.tableview.indexPathForRowAtPoint(buttonPosition)
        let delName = ObjectService.sharedService.objects[indexPath!.row].name
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteObject(self.container!.name, objectName: delName, url: user.objectStorageServiceURL, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("ObjectDeleted", obj: "deleted")
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
                        }
                    default:
                        errorMessage = "Action failed."
                    }
                    PromptErrorMessage(errorMessage, viewController: self, callback: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    })
            }
        }
        
    }
    
    // List actions that can be done to a container
    func containerAction(sender: UIButton){
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem1 = YXJKxMenuItem("Upload Object", image: nil, target: self, action: #selector(ContainerDetailViewController.createFolder(_:)))
        menuArray.append(menuItem1)
        
        YXJKxMenu.setTitleFont(UIFont.systemFontOfSize(14))
        
        let option = OptionalConfiguration(
            arrowSize: 10,
            marginXSpacing: 10,
            marginYSpacing: 10,
            intervalSpacing: 10,
            menuCornerRadius: 3,
            maskToBackground: true,
            shadowOfMenu: false,
            hasSeperatorLine: true,
            seperatorLineHasInsets: false,
            textColor: Color(R: 82 / 255.0, G: 82 / 255.0, B: 82 / 255.0),
            menuBackgroundColor: Color(R: 1, G: 1, B: 1),
            setWidth: (ScreenWidth - 20 * 2) / 2)

        let rect = CGRect(x: sender.frame.origin.x, y: 60, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
    }
    
    // Jump to another interface to create a new object or folder for the container
    func createFolder(item: YXJKxMenuItem){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("CreateFolderViewController") as! CreateFolderViewController
            
            editVc.containerName = ContainerService.sharedService.containers[self.index!].name
            
            
            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
}

