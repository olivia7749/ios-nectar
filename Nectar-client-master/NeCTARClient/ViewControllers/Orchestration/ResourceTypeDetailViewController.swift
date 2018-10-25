//
//  ResourceTypeDetailViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 1/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import YXJKxMenu
import MBProgressHUD
import SwiftyJSON

// Show details of a resource type according to the associated resource type's index
class ResourceTypeDetailViewController: BaseViewController {
    var type: ResourceType?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    var hudParentView = UIView()
    var attributesList : String?
    var propertiesList : String?
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var Attributes: UILabel!
    @IBOutlet var Properties: UILabel!
    
    var actionViewController: ActionsViewController!
    var centerOfBeginning: CGPoint!
    var existConfigGroup: Bool!
    var haveConfigGroup: Bool!
    
    // load data
    
    func commonInit() {
        
        if let user = UserService.sharedService.user {
            NeCTAREngine.sharedEngine.queryResourceType(user.orchestrationServiceURL, typeName: type!.type, token: user.tokenID).then{ (json) -> Void in
                print("resource type details for \(self.index)")
                print(json)
                self.attributesList = json["attributes"].description
                self.propertiesList = json["properties"].description
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get resource type details."
                        }
                    default:
                        errorMessage = "Fail to get resource type details."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
        
        
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.setContent()
        }
        
    }
    
    
    
    func setContent() {
        Attributes.text = self.propertiesList
        Properties.text = self.propertiesList

    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
}
