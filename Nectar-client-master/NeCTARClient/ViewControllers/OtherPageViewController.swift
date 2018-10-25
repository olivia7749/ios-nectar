//
//  OtherPageViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD

class OtherPageViewController: BaseViewController {
    
    @IBOutlet var label: UILabel!
    var PageTitle: String!
    var otherVC: UIViewController? = nil
    var addInstanceImageViewController: AddInstanceImageViewController!
    var addInstanceVolumeViewController: AddInstanceVolumeViewController!
    var importKeyViewController: ImportKeyViewController!
    var addVolumeViewController: AddVolumeViewController!
    var addRouterViewController: AddRouterViewController!
    var addFloatingIPViewController: AddFloatingIPViewController!
    var addContainerViewController: AddContainerViewController!
    var addNetworkViewController: AddNetworkViewController!
    var addDatabaseInstanceViewController: AddDataInsViewController!
    var addConfigGroupViewController: AddConfigGroupViewController!
    var hudParentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        
        hudParentView = self.view
        
        switch PageTitle {
        case "Instance":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InstancesViewController") as! InstancesViewController
            self.navigationItem.title = "Instances"
            let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addInstance),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
        case "About":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
            self.navigationItem.title = "About"
            
        case "Volumes":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("VolumeAndSnapshotViewController") as! VolumeAndSnapshotViewController
            self.navigationItem.title = "Volumes"
            let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addVolume),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
            
        case "Images":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
            self.navigationItem.title = "Images"
        case "Access & Security":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SecurityAndKeyViewController") as! SecurityAndKeyViewController
            self.navigationItem.title = "Security Groups & Keys"
            let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addSecurityOrKey),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
        case "Routers":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RoutersViewController") as! RoutersViewController
            self.navigationItem.title = "Routers"
            let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addRouter),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
        case "Floating IPs":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FloatingIPsViewController") as! FloatingIPsViewController
            self.navigationItem.title = "Floating IPs"
            let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addFloatingIP),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
        case "Containers":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContainersViewController") as! ContainersViewController
            self.navigationItem.title = "Containers"
            let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addContainer),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
            
        case "Networks":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NetworksViewController") as! NetworksViewController
            self.navigationItem.title = "Networks"
            let btn1=UIButton(frame: CGRectMake(0, 0, 50, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addNetwork),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
            
        case "Database Instances":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DatabaseViewController") as! DatabaseViewController
            self.navigationItem.title = "Database"
            let btn1=UIButton(frame: CGRectMake(0, 0, 50, 30))
            btn1.setImage(UIImage(named: "addContent"), forState: UIControlState.Normal)
            btn1.setImage(UIImage(named: "addContentGrey"), forState: UIControlState.Highlighted)
            btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btn1.addTarget(self, action:#selector(OtherPageViewController.addDatabaseActions),forControlEvents:.TouchUpInside)
            let item2=UIBarButtonItem(customView: btn1)
            self.navigationItem.rightBarButtonItem=item2
            
        case "Orchestration":
            otherVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OrchestrationViewController") as! OrchestrationViewController
            self.navigationItem.title = "Orchestration"
            
        default:
            let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
            viewController.showHome()
            
        }
        
        if let otherVC = otherVC {
            self.addChildViewController(otherVC)
            self.view.addSubview(otherVC.view)
            otherVC.didMoveToParentViewController(self)
            
        }
        
    }
    
    
    
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addVolume(sender: UIButton) {
        
        self.addVolumeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddVolumeViewController") as! AddVolumeViewController
        
        self.navigationController?.pushViewController(self.addVolumeViewController, animated: true)
        print("here1")
        
        MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
        
        
    }
    
    func addInstance(sender: UIButton) {
        
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem = YXJKxMenuItem("Boot from Image", image: nil, target: self, action: #selector(OtherPageViewController.addInstanceImage(_:)))
        menuArray.append(menuItem!)
        
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
            setWidth: (ScreenWidth - 15 * 2) / 2)
        
        let rect = CGRect(x: sender.frame.origin.x, y: 0, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
    }
    
    func addInstanceImage(item: YXJKxMenuItem){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addInstanceImageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddInstanceImageViewController") as! AddInstanceImageViewController
            
            self.navigationController?.pushViewController(self.addInstanceImageViewController, animated: true)
            print("here1")
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    
    func addInstanceVolume(item: YXJKxMenuItem){
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addInstanceVolumeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddInstanceVolumeViewController") as! AddInstanceVolumeViewController
            
            self.navigationController?.pushViewController(self.addInstanceVolumeViewController, animated: true)
            print("here1")
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    
    func commonInit(){
        if let user = UserService.sharedService.user{
            let url = user.imageServiceURL + "v2/images"
            let token = user.tokenID
            
            let owner = "28eadf5ad64b42a4929b2fb7df99275c"
            let selfOwner = user.owner
            
            NeCTAREngine.sharedEngine.listImages(url, token: token, owner: selfOwner).then{ (json) -> Void in
                ImageService.sharedService.clear()
                let images = json["images"].arrayValue
                for one in images {
                    let instance = Image(json: one)
                    ImageService.sharedService.images.append(instance!)
                    
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
                            errorMessage = "Fail to get images"
                        }
                    default:
                        errorMessage = "Fail to get images"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            NeCTAREngine.sharedEngine.listImages(url, token: token, owner: owner).then{ (json) -> Void in
                
                let images = json["images"].arrayValue
                for one in images {
                    let instance = Image(json: one)
                    ImageService.sharedService.images.append(instance!)
                    
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
                            errorMessage = "Fail to get images"
                        }
                    default:
                        errorMessage = "Fail to get images"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            NeCTAREngine.sharedEngine.listFlavors(user.computeServiceURL, token: token).then{ (json) -> Void in
                let flavors = json["flavors"].arrayValue
                FlavorService.sharedService.clear()
                for one in flavors {
                    let instance = Flavor(json: one)
                    FlavorService.sharedService.falvors.append(instance!)
                    
                    
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
                            errorMessage = "Fail to get flavor"
                        }
                    default:
                        errorMessage = "Fail to get flavor"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            NeCTAREngine.sharedEngine.listKeyPair(user.computeServiceURL, token: token).then{ (json) -> Void in
                let keys = json["keypairs"].arrayValue
                KeyService.sharedService.clear()
                for one in keys {
                    let instance = Key(json: one)
                    KeyService.sharedService.keys.append(instance!)
                    
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
                            errorMessage = "Fail to get flavor"
                        }
                    default:
                        errorMessage = "Fail to get flavor"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            NeCTAREngine.sharedEngine.listSecurityGroups(user.networkServiceURL, token: token).then{ (json) -> Void in
                let securities = json["security_groups"].arrayValue
                SecurityService.sharedService.clear()
                for one in securities {
                    let instance = Security(json: one)
                    SecurityService.sharedService.securities.append(instance!)
                    
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
                            errorMessage = "Fail to get flavor"
                        }
                    default:
                        errorMessage = "Fail to get flavor"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            NeCTAREngine.sharedEngine.listZone(user.computeServiceURL, token: token).then{ (json) -> Void in
                let azones = json["availabilityZoneInfo"].arrayValue
                AZoneService.sharedService.clear()
                for one in azones {
                    let azone = AZone(json: one)
                    AZoneService.sharedService.azones.append(azone!)
                    
                    
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
                            errorMessage = "Fail to get availability zone"
                        }
                    default:
                        errorMessage = "Fail to get availability zone"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
    }
    
    
    
    func addSecurityOrKey(sender: UIButton){
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem = YXJKxMenuItem("Add Security Group", image: nil, target: self, action: #selector(OtherPageViewController.addSecurity(_:)))
        menuArray.append(menuItem!)
        let menuItem1 = YXJKxMenuItem("Add Key", image: nil, target: self, action: #selector(OtherPageViewController.addKey(_:)))
        menuArray.append(menuItem1!)
        let menuItem2 = YXJKxMenuItem("Import Key", image: nil, target: self, action: #selector(OtherPageViewController.importKey(_:)))
        menuArray.append(menuItem2!)
        
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
            setWidth: (ScreenWidth - 15 * 2) / 2)
        
        let rect = CGRect(x: sender.frame.origin.x, y: 0, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
    }
    
    func addDatabaseActions(sender: UIButton){
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem = YXJKxMenuItem("Add Database Instance", image: nil, target: self, action: #selector(OtherPageViewController.addDatabaseInstance(_:)))
        menuArray.append(menuItem!)
        let menuItem1 = YXJKxMenuItem("Add Configuration Group", image: nil, target: self, action: #selector(OtherPageViewController.addConfigurationGroup(_:)))
        menuArray.append(menuItem1!)
        
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
            setWidth: (ScreenWidth - 15 * 2) / 2)
        
        let rect = CGRect(x: sender.frame.origin.x, y: 0, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
    }
    
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    var ScreenHeight: CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }
    
    func addSecurity(item: YXJKxMenuItem){
        let alertController = UIAlertController(title: "Create Security Group", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = "Security Group Name"
        }
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = "Description"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
            let nameField = (alertController.textFields?.first)! as UITextField
            let descritptionField = (alertController.textFields?.last)! as UITextField
            let name = nameField.text
            let descritption = descritptionField.text
            let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if let user = UserService.sharedService.user{
                
                if name!.stringByTrimmingCharactersInSet(whitespace).isEmpty {
                    PromptErrorMessage("Security Group name is invalid.", viewController: self)
                } else {
                    
                    MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    
                    NeCTAREngine.sharedEngine.createSecurityGroup(name!, description: descritption!, url:user.networkServiceURL, token: user.tokenID).then{
                        (json) -> Void in
                        print("create security")
                        let msg = "Please refresh."
                        let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error {
                            (err) -> Void in
                            print(err)
                            var errorMessage:String = "Action Failed."
                            switch err {
                            case NeCTAREngineError.CommonError(let msg):
                                errorMessage = msg!
                            default:
                                errorMessage = "Fail to create the security group."
                            }
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
                }
                
            }
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    func addKey(item: YXJKxMenuItem){
        
        let alertController = UIAlertController(title: "Create Key Pair", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Key Pair Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
        let okAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) -> Void in
            let nameField = (alertController.textFields?.first)! as UITextField
            let name = nameField.text
            let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            
            if let user = UserService.sharedService.user{
                
                if name!.stringByTrimmingCharactersInSet(whitespace).isEmpty {
                    PromptErrorMessage("Key Pair name is invalid.", viewController: self)
                } else {
                    MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.createKeyPair(name!, url:user.computeServiceURL, token: user.tokenID).then{
                        (json) -> Void in
                        print("create key")
                        let msg = "The key pair will download automatically. Please refresh."
                        let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        print(json)
                        
                        let fileName:String = name! + ".pem"
                        let filePath:String = NSHomeDirectory() + "/Documents/" + fileName
                        let info = json["keypair"]["private_key"].stringValue
                        try info.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
                        
                        
                        
                        let manager = NSFileManager.defaultManager()
                        let urlsForDocDirectory = manager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
                        let docPath:NSURL = urlsForDocDirectory[0] as NSURL
                        let file = docPath.URLByAppendingPathComponent(fileName)
                        
                        let data = manager.contentsAtPath(file.path!)
                        let readString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print(readString)
                        
                        let contentsOfPath = try manager.contentsOfDirectoryAtPath(docPath.path!)
                        print("contentsOfPath: \(contentsOfPath)")
                        
                        
                        
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error {
                            (err) -> Void in
                            print(err)
                            var errorMessage:String = "Action Failed."
                            switch err {
                            case NeCTAREngineError.CommonError(let msg):
                                errorMessage = msg!
                            default:
                                errorMessage = "Fail to create the key pair."
                            }
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
                }
            }
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func importKey(item: YXJKxMenuItem)
    {
        self.importKeyViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ImportKeyViewController") as! ImportKeyViewController
        
        self.navigationController?.pushViewController(self.importKeyViewController, animated: true)
        
    }
    func addRouter(sender: UIButton) {
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addRouterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddRouterViewController") as! AddRouterViewController
            
            self.navigationController?.pushViewController(self.addRouterViewController, animated: true)
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    func addFloatingIP(sender: UIButton) {
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addFloatingIPViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddFloatingIPViewController") as! AddFloatingIPViewController
            
            self.navigationController?.pushViewController(self.addFloatingIPViewController, animated: true)
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    
    func addContainer(sender: UIButton) {
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addContainerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddContainerViewController") as! AddContainerViewController
            
            self.navigationController?.pushViewController(self.addContainerViewController, animated: true)
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    
    func addNetwork(sender: UIButton) {
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addNetworkViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddNetworkViewController") as! AddNetworkViewController
            
            self.navigationController?.pushViewController(self.addNetworkViewController, animated: true)
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    
    func addDatabaseInstance(item: YXJKxMenuItem) {
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addDatabaseInstanceViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddDataInsViewController") as! AddDataInsViewController
            
            self.navigationController?.pushViewController(self.addDatabaseInstanceViewController, animated: true)
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }
    
    func addConfigurationGroup(item: YXJKxMenuItem) {
        
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        commonInit()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            
            self.addConfigGroupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddConfigGroupViewController") as! AddConfigGroupViewController
            
            self.navigationController?.pushViewController(self.addConfigGroupViewController, animated: true)
            
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
    }

}
