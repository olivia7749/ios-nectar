//
//  ActionsViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/9/21.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

class ActionsViewController: BaseViewController {

    var backImage: UIImage?
    var instance: Instance?
    var instanceIndex: Int?
    var upIndex = 0
    var downIndex = 0
    
    var buttons: [UIButton] = []
    var timer: NSTimer = NSTimer()
    var closeImageView = UIImageView()
    var hudParentView = UIView()

    override func loadView() {
        super.loadView()
        
        let view = UIView(frame: UIScreen.mainScreen().bounds)
        let imageView = UIImageView(image: self.backImage)
        
        let blurView = UIView(frame: UIScreen.mainScreen().bounds)
        
        blurView.backgroundColor = UIColor(white: 0.9, alpha: 0.8)
        imageView.addSubview(blurView)
        view.addSubview(imageView)
       
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hudParentView = self.view
        
        // Do any additional setup after loading the view.
        
        self.setMenu()
        
        self.setCloseImage()
        
        timer = NSTimer.scheduledTimerWithTimeInterval (0.1, target: self, selector: #selector(self.popupBtn), userInfo: nil, repeats: true)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.touch(_:)))
        
        self.view.addGestureRecognizer(gesture)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animateWithDuration(0.6, animations:{ () -> Void in
            self.closeImageView.transform = CGAffineTransformRotate(self.closeImageView.transform,CGFloat(M_PI))
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popupBtn() {
        if (upIndex == self.buttons.count) {
            self.timer.invalidate()
            upIndex = 0
            return
        }
        let btn = self.buttons[upIndex];
        self.popOutOneBtn(btn)
        upIndex += 1
    }
    
    func popOutOneBtn(button: UIButton) {
        
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            button.transform = CGAffineTransformIdentity
            }, completion: { (finished) -> Void in
                self.downIndex = self.buttons.count - 1
        })
    }
    
    func setMenu() {
        let columns = 3
        var col = 0
        var row = 0
        
        let width:CGFloat = 100
        let height:CGFloat = 80
        
        let margin = (UIScreen.mainScreen().bounds.size.width - CGFloat(columns) * width) / (CGFloat(columns) + 1)
        
        var titles: [String] = []
        
        // change the enabled button according to different instance status
        switch (instance?.status)! {
            
        case "SUSPENDED":
            titles = ["Resume", "Create Snapshot", "Delete"]
            
        case "PAUSED":
            titles = ["Unpause","Create Snapshot", "Delete"]
            
        case "SHUTOFF":
            titles = ["Start", "HardReboot", "SoftReboot", "Create Snapshot", "Delete"]
            
        default:
            titles = ["Pause", "Suspend", "Stop", "HardReboot", "SoftReboot", "Create Snapshot", "Delete"]
        }
       
        
        var originY:CGFloat = 300
        
        switch UIScreen.mainScreen().bounds.height {
        case 480:
            originY = 113
        case 568:
            originY = 200
        case 736:
            originY = 369
        default:
            originY = 300
        }
        
        
        // computing the postion of each button and add them to view
        for i in 0 ..< titles.count {
            
            let btn =  SelfDefineButton()
            
            btn.imageView?.contentMode = UIViewContentMode.Center
            btn.titleLabel?.textAlignment = NSTextAlignment.Center
            btn.setTitleColor(UIColor.blackColor(), forState:UIControlState.Normal)
            btn.titleLabel?.font = UIFont.systemFontOfSize(12)
            
            let image = UIImage(named: "button")
            btn.setImage(image, forState: UIControlState.Normal)
            
            let disableImage = UIImage(named: "disableButton")
            btn.setImage(disableImage, forState: UIControlState.Disabled)
            
            btn.setTitle(titles[i], forState: UIControlState.Normal)
                
            col = i % columns
            row = i / columns

            
            let x = margin + CGFloat(col) * (margin + width)
            let y = CGFloat(row) * (margin + height) + originY
            
            btn.frame = CGRectMake(x, y, width, height)
            btn.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height)
            
            btn.addTarget(self, action: #selector(self.btnOnTouch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons.append(btn)
            
            self.view.addSubview(btn)
        }
        
        
    }
    
    // when the button touched, do differernt action and change status
    func btnOnTouch (btn: UIButton) {
        UIView.animateWithDuration(0.5, animations:{ () -> Void in
            btn.transform = CGAffineTransformMakeScale(2.0, 2.0)
            btn.alpha = 0
        })
        if let user = UserService.sharedService.user{
            switch btn.currentTitle! {
            case "Pause":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "pause", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "PAUSED"
                            self.changeInstanceStatus()
                        self.postNotification("StatusChanged", obj: "PAUSED")
                        
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)

                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error { (err) -> Void in
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
            case "Unpause":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "unpause", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "ACTIVE"
                            self.changeInstanceStatus()
                        self.postNotification("StatusChanged", obj: "ACTIVE")
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error { (err) -> Void in
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

            case "Suspend":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "suspend", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "SUSPENDED"
                            self.changeInstanceStatus()
                        self.postNotification("StatusChanged", obj: "SUSPENDED")
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error { (err) -> Void in
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
            case "Resume":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "resume", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "ACTIVE"
                            self.changeInstanceStatus()
                        self.postNotification("StatusChanged",obj: "ACTIVE")
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error { (err) -> Void in
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
                
            case "Stop":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "stop", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "SHUTOFF"
                            self.changeInstanceStatus()
                        self.postNotification("StatusChanged",obj: "SHUTOFF")
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error { (err) -> Void in
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
            case "Start":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.instanceAction((self.instance?.id)!, url: user.computeServiceURL, action: "start", token: user.tokenID).then { (json)
                        -> Void in
                            print(json)
                            self.instance?.status = "ACTIVE"
                            self.changeInstanceStatus()
                        
                        self.postNotification("StatusChanged", obj: "ACTIVE")
                        let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error { (err) -> Void in
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
                

            case "HardReboot":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                NeCTAREngine.sharedEngine.rebootInstance((self.instance?.id)!, method: "HARD", url: user.computeServiceURL, token: user.tokenID).then{ (json) -> Void in
                    print (json)
                    self.instance?.status = "ACTIVE"
                    self.changeInstanceStatus()
                    self.postNotification("StatusChanged", obj: "ACTIVE")
                    let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    }.always{
                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                    }.error{ (err) -> Void in
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

            case "SoftReboot":
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                NeCTAREngine.sharedEngine.rebootInstance((self.instance?.id)!, method: "SOFT", url: user.computeServiceURL, token: user.tokenID).then { (json) -> Void in
                    print (json)
                    self.instance?.status = "ACTIVE"
                    self.changeInstanceStatus()
                    self.postNotification("StatusChanged", obj: "ACTIVE")
                    let alert = UIAlertController(title: "Success", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    }.always{
                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                    }.error{ (err) -> Void in
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

            case "Create Snapshot":
                createSnapshot()
        
// API is not usable
//            case "Usage":
//                NeCTAREngine.sharedEngine.checkServerUsage((self.instance?.id)!, url: user.computeServiceURL, token: user.tokenID).then{ (json) -> Void in
//                    print(json)
//                }
//                
            default:
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                NeCTAREngine.sharedEngine.deleteInstance((self.instance?.id)!, url: user.computeServiceURL, token: user.tokenID).then {
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
    
    // create snapshot of a instance
    func createSnapshot () {
        
        let alertController = UIAlertController(title: "Create image snapshot", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Name for snapshot"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
            let nameField = (alertController.textFields?.first)! as UITextField
            let name = nameField.text
            if let user = UserService.sharedService.user{
                MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                NeCTAREngine.sharedEngine.createSnapshot((self.instance?.id)!, url:user.computeServiceURL , snapshotName: name!, token: user.tokenID).then{
                    (json) -> Void in
                    
                    let msg = "Please refresh after 10 seconds."
                    let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    }.always{
                        MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                    }.error {
                        (err) -> Void in
                        var errorMessage:String = "Action Failed."
                        switch err {
                        case NeCTAREngineError.CommonError(let msg):
                            errorMessage = msg!
                        default:
                            errorMessage = "Fail to create the snapshot."
                        }
                        PromptErrorMessage(errorMessage, viewController: self, callback: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        })
                }
            }
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // make the instance status changed
    func changeInstanceStatus() {
        InstanceService.sharedService.instances[instanceIndex!].status = self.instance!.status
    }
    
    // the close image of the pop out menu
    func setCloseImage () {
        
        let img = UIImage(named: "cross")
        
        closeImageView = UIImageView(image: img)
        
        closeImageView.frame = CGRectMake(self.view.center.x-15, self.view.frame.size.height-45, 30, 30);
        
        self.view.addSubview(closeImageView)
        
    }

    // for dismiss button
    func dismissButton() {
        if (downIndex == -1) {
            self.timer.invalidate()
            
            return
        }
        let btn = self.buttons[downIndex]
        
        self.setDownOneBtn(btn)
        self.downIndex -= 1
    }
    
    func setDownOneBtn(button: UIButton) {
        
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            button.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height)
            }, completion: { (finished) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    
    func touch(gesture: UIGestureRecognizer) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:#selector(dismissButton), userInfo:nil, repeats:true)
        
        UIView.animateWithDuration(0.3, animations:{ () -> Void in
            self.closeImageView.transform = CGAffineTransformRotate(self.closeImageView.transform, CGFloat(-M_PI_2*1.5))
        })
    }
    
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
