//
//  AddRouterViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 16/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

// Create a new router according to the parameters provided by the user
class AddRouterViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pickview: UIView!
    @IBOutlet var basetable: UIView!
    
    @IBOutlet var name: UITextField!
    @IBOutlet var adminState: UITextField!
    @IBOutlet var externalNetwork: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var adminStatePick: UIPickerView!
    @IBOutlet var externalNetworkPick: UIPickerView!
    
    var pick = ""
    var previous = ""
    var previousone = ""
    var now = ""
    var nowid = ""
    
    var routerIndex: Int!
    var routerId: String!
    
    // An array of available external network
    let externalNetworkP: [String] = ["-","QRIScloud","tasmania","auckland","melbourne"]
    let externalNetworkId:[String] = ["","058b38de-830a-46ab-9d95-7a614cb06f1b","24dbaea8-c8ab-43dc-ba5c-0babc141c20e", "60e0be0e-5021-4574-8650-dbf92e1a9cfe", "e48bdd06-cc3e-46e1-b7ea-64af43c74ef8"]
    
    var adminStateP: [String] = ["enable admin state", "unenable admin state"]
    var adminStateId:[String] = ["true", "false"]
    
    
    
    var singleAdminStateRef: String = ""
    var singleExternalNetworkRef: String = ""
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    
    
    func commonInit(){
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Router"
        
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside) //Click the button to start creating the router
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        commonInit()
        
        adminStatePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        externalNetworkPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        
        adminStatePick.hidden = true
        externalNetworkPick.hidden = true
        
        adminState.inputView = adminStatePick
        externalNetwork.inputView = externalNetworkPick
        
        done.hidden = true
        cancel.hidden = true
        
        done.enabled = true
        cancel.enabled = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        hudParentView = self.view
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "RouterCreated", object: nil)
        
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneClick(_:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        
        
    }
    
    func returnBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func postNotification(notiName: String, obj: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notiName, object: obj)
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        if let _ = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    
    func tap(sender:AnyObject) {
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows : Int = 0
        if pickerView == adminStatePick {
            countrows = adminStateP.count
        } else if pickerView == externalNetworkPick {
            countrows = externalNetworkP.count
        }
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == adminStatePick {
            self.view.endEditing(true)
            let titleRow = adminStateP[row]
            return titleRow
            
        } else if pickerView == externalNetworkPick{
            self.view.endEditing(true)
            let titleRow = externalNetworkP[row]
            return titleRow
        }
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == adminStatePick {
            self.adminState.text = self.adminStateP[row]
            singleAdminStateRef = self.adminStateId[row]
        } else if pickerView == externalNetworkPick {
            self.externalNetwork.text = self.externalNetworkP[row]
            singleExternalNetworkRef = self.externalNetworkId[row]
        }
        
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.adminState){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            adminStatePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "admin state"
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 151, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 194
            if let _ = activeField
            {
                if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
            }
            
            return false
            
        } else if (textField == self.externalNetwork){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            externalNetworkPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "external network"
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 151, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 194
            if let _ = activeField
            {
                if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
            }
            
            return false
            
        } else {
            textField.endEditing(true)
            return true
        }
        
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        self.view.endEditing(true)
        if (pick == "admin state"){
            adminState.resignFirstResponder()
            basetable.userInteractionEnabled = true
            adminStatePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "external network"){
            externalNetwork.resignFirstResponder()
            basetable.userInteractionEnabled = true
            externalNetworkPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "admin state"){
            adminState.text = ""
            adminStatePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            
        } else if (pick == "external network"){
            externalNetwork.text = ""
            externalNetworkPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        if pickerView == adminStatePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.adminStateP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == externalNetworkPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.externalNetworkP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        return pickerLabel
    }
    
    // Request Openstack to create the router according to user settings
    func createClick() {
        
        guard let routertext = self.name.text where !routertext.isEmpty else{
            PromptErrorMessage("Router name cannot be empty", viewController: self)
            return
        }
        guard let adminStatetext = self.adminState.text where !adminStatetext.isEmpty else{
            PromptErrorMessage("Admin state cannot be empty", viewController: self)
            return
        }
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.createRouter(user.networkServiceURL, name: routertext, snat: "true",external_gateway_info: singleExternalNetworkRef, admin_state_up: singleAdminStateRef, token: user.tokenID).then{
                (json) -> Void in
                print(json)
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("RouterCreated", obj: "created")
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                }.always{
                    self.scrollView.userInteractionEnabled = true
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }.error{(err) -> Void in
                    
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    default:
                        errorMessage = "Router information is incorrect."
                        
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
        }
        
        
        
    }
    
}
