//
//  DatabaseInstanceDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 27/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

class DatabaseInstanceDetailViewController: BaseViewController {
    var databaseInstance: DatabaseInstance?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()
    
    @IBOutlet var name: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var datastore: UILabel!
    @IBOutlet var datastoreVersion: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var rootEnabled: UILabel!
    @IBOutlet var flavorName: UILabel!
    @IBOutlet var volumeSize: UILabel!
    @IBOutlet var created: UILabel!
    @IBOutlet var updated: UILabel!
    
    var actionViewController: ActionsViewController!
    var centerOfBeginning: CGPoint!
    var existConfigGroup: Bool!
    var haveConfigGroup: Bool!
    
    // load data
    
    func commonInit() {
        if ConfigurationGroupService.sharedService.configutationGroups.count == 0{
            existConfigGroup = false
            haveConfigGroup = false
        } else {
            existConfigGroup = true
            haveConfigGroup = false
            for group in ConfigurationGroupService.sharedService.configutationGroups {
                if let user = UserService.sharedService.user {
                    NeCTAREngine.sharedEngine.listInstanceForConfigGroup(user.databaseServiceURL, configId: group.id, token: user.tokenID).then{ (json) -> Void in
                        let instances = json["instances"].arrayValue
                        for instance in instances {
                            if instance["id"].stringValue == self.databaseInstance?.id {
                                self.haveConfigGroup = true
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
                                    errorMessage = "Fail to get all instances for configuration group."
                                }
                            default:
                                errorMessage = "Fail to get all instance for configuration group."
                            }
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
                    
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        setContent()
        
        let btn=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn.setImage(UIImage(named: "editBlack"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "editGrey"), forState: UIControlState.Highlighted)
        
        // Add buttons for actions that can be applied on the database instance
        btn.addTarget(self, action:#selector(DatabaseInstanceDetailViewController.actions),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "InstanceDeleted", object: nil)
        
    }
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    func returnBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func returnToRootView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Set contents that will be showed in the interface
    func setContent() {
        
        name.text = self.databaseInstance?.name
        id.text = self.databaseInstance?.id
        datastore.text = self.databaseInstance?.datastore
        datastoreVersion.text = self.databaseInstance?.datastoreVersion
        status.text = self.databaseInstance?.status
        rootEnabled.text = self.databaseInstance?.rootEnabled
        flavorName.text = self.databaseInstance?.flavorName
        volumeSize.text = self.databaseInstance?.volumeSize
        created.text = self.databaseInstance?.created
        updated.text = self.databaseInstance?.updated
        
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    func actions(sender: UIButton){
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem1 = YXJKxMenuItem("Resize Volume", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.resizeVolumeSize(_:)))
        menuArray.append(menuItem1!)
        
        if self.databaseInstance?.rootEnabled == "No" {
            let menuItem2 = YXJKxMenuItem("Enable Root User", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.enableRoot(_:)))
            menuArray.append(menuItem2!)
        } else if self.databaseInstance?.rootEnabled == "Yes" {
            let menuItem2 = YXJKxMenuItem("Disable Root User", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.disableRoot(_:)))
            menuArray.append(menuItem2!)
        }
        
        if self.existConfigGroup == true {
            if self.haveConfigGroup == false {
                let menuItem3 = YXJKxMenuItem("Attach Configuration Group", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.attachConfig(_:)))
                menuArray.append(menuItem3!)
                
            } else {
                let menuItem3 = YXJKxMenuItem("Ditach Configuration Group", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.distachConfig(_:)))
                menuArray.append(menuItem3!)
            }}
        
        let menuItem4 = YXJKxMenuItem("Restart Instance", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.restartIns(_:)))
        menuArray.append(menuItem4!)
        
        let menuItem5 = YXJKxMenuItem("Delete Instance", image: nil, target: self, action: #selector(DatabaseInstanceDetailViewController.deleteInstance(_:)))
        menuArray.append(menuItem5!)
        
        // Basic settings for a YXJKx button
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
            setWidth: (ScreenWidth + 10) / 2)
        
        let rect = CGRect(x: sender.frame.origin.x, y: 0, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
    }
    
    // Request Openstack to delete the instance
    func deleteInstance(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteDatabaseInstance(user.databaseServiceURL, instanceId: self.databaseInstance!.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("InstanceDeleted", obj: "deleted")
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
                        } else if code == 409 {
                            
                            errorMessage = "Action failed."
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
    
    // Request Openstack to restart the instance
    func restartIns(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.restartDatabaseInstance(user.databaseServiceURL, instanceId: self.databaseInstance!.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("InstanceRestarted", obj: "restarted")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Restart Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
                        } else if code == 409 {
                            
                            errorMessage = "Action failed."
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
    
    // Request Openstack to resize the instance
    func resizeVolumeSize(item: YXJKxMenuItem){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("ResizeVolumeForDatabaseIns") as! ResizeVolumeForDatabaseIns
            
            editVc.instanceId = self.databaseInstance!.id
            
            
            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
    // Request Openstack to attach a configuration group to the instance
    func attachConfig(item: YXJKxMenuItem){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("AttachConfigGroupViewController") as! AttachConfigGroupViewController
            
            editVc.instanceId = self.databaseInstance!.id
            
            
            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
    // Request Openstack to distach a configuration group from the instance
    func distachConfig(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.detachDatabaseInstanceConfig(user.databaseServiceURL, instanceId: self.databaseInstance!.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("ConfigurationGroupDetached", obj: "detached")
                let msg = "Please refresh after 10 seconds."
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
                        } else if code == 409 {
                            
                            errorMessage = "Action failed."
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
    
    // Request Openstack enable root to the instance
    func enableRoot(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.enableDatabaseInstanceRoot(user.databaseServiceURL, instanceId: self.databaseInstance!.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("RootEnabled", obj: "enabled")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Enable root Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
                        } else if code == 409 {
                            
                            errorMessage = "Action failed."
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
    
    // Request Openstack to disable root to the instance
    func disableRoot(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.disableDatabaseInstanceRoot(user.databaseServiceURL, instanceId: self.databaseInstance!.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("RootDisabled", obj: "disabled")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Disable root Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
                        } else if code == 409 {
                            
                            errorMessage = "Action failed."
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
}
