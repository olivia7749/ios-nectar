//
//  StacksDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 4/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

class StacksDetailViewController: BaseViewController {
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()
    
    @IBOutlet var name: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var rollback: UILabel!
    @IBOutlet var descrip: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var statusReason: UILabel!
    @IBOutlet var created: UILabel!
    @IBOutlet var updated: UILabel!
    
    var centerOfBeginning: CGPoint!
    var existConfigGroup: Bool!
    var haveConfigGroup: Bool!
    
    // load data
    
    func commonInit() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        setContent()
        
        let btn=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn.setImage(UIImage(named: "editBlack"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "editGrey"), forState: UIControlState.Highlighted)
        
        // Add buttons for actions that can be applied on the stack
        btn.addTarget(self, action:#selector(StacksDetailViewController.actions),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "StackDeleted", object: nil)
        
    }
    
    func actions(sender: UIButton){
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem1 = YXJKxMenuItem("Suspend", image: nil, target: self, action: #selector(StacksDetailViewController.suspend(_:)))
        menuArray.append(menuItem1!)
        
        
        let menuItem2 = YXJKxMenuItem("Resume", image: nil, target: self, action: #selector(StacksDetailViewController.resume(_:)))
        menuArray.append(menuItem2!)
        
        
        let menuItem3 = YXJKxMenuItem("Check", image: nil, target: self, action: #selector(StacksDetailViewController.check(_:)))
        menuArray.append(menuItem3!)
        
        let menuItem4 = YXJKxMenuItem("Delete", image: nil, target: self, action: #selector(StacksDetailViewController.deleteStack(_:)))
        menuArray.append(menuItem4!)
        
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
            setWidth: (ScreenWidth - 10) / 2)
        
        let rect = CGRect(x: sender.frame.origin.x, y: 0, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
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
        
        name.text = StackService.sharedService.stacks[self.index!].name
        id.text = StackService.sharedService.stacks[self.index!].id
        status.text = StackService.sharedService.stacks[self.index!].status
        statusReason.text = StackService.sharedService.stacks[self.index!].statusReason
        descrip.text = StackService.sharedService.stacks[self.index!].descrip
        created.text = StackService.sharedService.stacks[self.index!].created
        updated.text = StackService.sharedService.stacks[self.index!].updated
        rollback.text = StackService.sharedService.stacks[self.index!].rollback
        
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    // Call the resume action from Openstack API
    func resume(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let stack = StackService.sharedService.stacks[self.index!]
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.resumeStack(user.orchestrationServiceURL, stackName: stack.name, stackId: stack.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("StackResumed", obj: "resumed")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Resume Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    // Call the suspend action from Openstack API
    func suspend(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let stack = StackService.sharedService.stacks[self.index!]
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.suspendStack(user.orchestrationServiceURL, stackName: stack.name, stackId: stack.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("StackSuspended", obj: "suspended")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Suspend Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    // Call the check action from Openstack API
    func check(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let stack = StackService.sharedService.stacks[self.index!]
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.checkStack(user.orchestrationServiceURL, stackName: stack.name, stackId: stack.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("StackChecked", obj: "checked")
                let msg = "Please refresh after 10 seconds."
                let alert = UIAlertController(title: "Check Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    // Call the delete action from Openstack API
    func deleteStack(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let stack = StackService.sharedService.stacks[self.index!]
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteStack(user.orchestrationServiceURL, stackName: stack.name, stackId: stack.id, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("StackDeleted", obj: "deleted")
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
    
    
}

