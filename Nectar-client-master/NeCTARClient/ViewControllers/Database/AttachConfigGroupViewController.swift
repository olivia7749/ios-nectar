//
//  DetachConfigGroupViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 30/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

// Attach a configuration group to a database instance according to the parameters provided by the user
class AttachConfigGroupViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pickview: UIView!
    @IBOutlet var basetable: UIView!
    
    @IBOutlet var configGroup: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var configGroupPick: UIPickerView!
    
    var singleConfigGroupRef: String = ""
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    var pick = ""
    var instanceId = ""
    
    var configGroupP: [String] = []
    var configGroupId: [String] = []
    
    func commonInit() {
        for group in ConfigurationGroupService.sharedService.configutationGroups {
            configGroupP.append(group.name)
            configGroupId.append(group.id)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "Attach Configuration Group"
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        commonInit()
        
        configGroupPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        configGroupPick.hidden = true
        configGroup.inputView = configGroupPick
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "ConfigurationGroupAttached", object: nil)
        
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
        if pickerView == configGroupPick {
            countrows = configGroupP.count
        }
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == configGroupPick {
            self.view.endEditing(true)
            let titleRow = configGroupP[row]
            return titleRow
        }
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == configGroupPick {
            self.configGroup.text = self.configGroupP[row]
            singleConfigGroupRef = self.configGroupId[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.configGroup){
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            configGroupPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "configGroup"
            
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
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        
        let pickerLabel = UILabel()
        if pickerView == configGroupPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.configGroupP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        return pickerLabel
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        self.view.endEditing(true)
        if (pick == "configGroup"){
            configGroup.resignFirstResponder()
            basetable.userInteractionEnabled = true
            configGroupPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "configGroup"){
            configGroup.text = ""
            configGroupPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    // Request Openstack to attach configuration group to a instance according to instance id
    func createClick() {
        
        guard let configurationGrouptext = self.configGroup.text where !configurationGrouptext.isEmpty else{
            PromptErrorMessage("Configuration group cannot be empty", viewController: self)
            return
        }
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.attachDatabaseInstanceConfig(user.databaseServiceURL, instanceId: self.instanceId, configId: self.singleConfigGroupRef, token: user.tokenID).then{
                
                (json) -> Void in
                print(json)
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Attach Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("ConfigurationGroupAttached", obj: "attached")
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
               
                }.always{
                    self.scrollView.userInteractionEnabled = true
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }.error{(err) -> Void in
                    
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else if code == 400 {
                            errorMessage = "Unable to attach configuration group to an instance whose root has been enabled."
                        }else {
                            errorMessage = "Action Failed."
                        }
                    default:
                        errorMessage = "Action Failed."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
        
        
        
    }
    
}
