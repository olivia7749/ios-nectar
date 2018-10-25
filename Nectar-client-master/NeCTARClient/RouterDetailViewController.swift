//
//  RouterDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 14/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//


import UIKit
import YXJKxMenu
import MBProgressHUD

// Show all details of the router
class RouterDetailViewController: BaseViewController {
    var router: Router?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()
    
    @IBOutlet var routerName: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var projectId: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var adminState: UILabel!
    @IBOutlet var networkName: UILabel!
    @IBOutlet var networkId: UILabel!
    @IBOutlet var subnetId: UILabel!
    @IBOutlet var ipAdress: UILabel!
    @IBOutlet var snat: UILabel!
    
    var actionViewController: ActionsViewController!
    var centerOfBeginning: CGPoint!
    
    // load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        
        let btn=UIButton(frame: CGRectMake(0, 0, 80, 30))
        btn.setTitle("Actions", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn.addTarget(self, action:#selector(RouterDetailViewController.routerAction),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem=item2
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(statusChanged), name: "StatusChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "RouterDeleted", object: nil)
        
    }
    
    func statusChanged() {
        status.text = RouterService.sharedService.routers[index!].status
        self.router?.status = RouterService.sharedService.routers[index!].status
    }
    
    func returnBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func returnToRootView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setContent() {
        
        routerName.text = router?.name
        id.text = router?.id
        projectId.text = router?.projectID
        status.text = router?.status
        adminState.text = router?.adminState
        networkName.text = router?.gatewayName
        networkId.text = router?.networkID
        subnetId.text = router?.subnetID
        ipAdress.text = router?.ipAddress
        snat.text = router?.snat
        
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var ScreenWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    func routerAction(sender: UIButton){
        var menuArray: [YXJKxMenuItem] = []
        
        let menuItem1 = YXJKxMenuItem("Edit Router", image: nil, target: self, action: #selector(RouterDetailViewController.editRouter(_:)))
        menuArray.append(menuItem1)
        let menuItem2 = YXJKxMenuItem("Delete Router", image: nil, target: self, action: #selector(RouterDetailViewController.deleteRouter(_:)))
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
            setWidth: (ScreenWidth - 20 * 2) / 2)
        
        let rect = CGRect(x: sender.frame.origin.x, y: 0, width: sender.frame.size.width, height: 5)
        
        YXJKxMenu.showMenuInView(self.view, fromRect: rect, menuItems: menuArray, withOptions: option)
        
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }

    // Request Openstack to delete a router according to its id
    func deleteRouter(item: YXJKxMenuItem){
        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.deleteRouter((self.router?.id)!, url: user.networkServiceURL, token: user.tokenID).then {
                (json) -> Void in
                print (json)
                self.postNotification("RouterDeleted", obj: "deleted")
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
    func editRouter(item: YXJKxMenuItem){

        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let editVc = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("EditRouterViewController") as! EditRouterViewController
            
            editVc.routerId = self.router?.id
            editVc.routerIndex = self.index

            self.navigationController?.pushViewController(editVc, animated: true)
            MBProgressHUD.hideAllHUDsForView(self.hudParentView, animated: true)
            
        }
        
    }
    
}
