//
//  AddConfigGroupViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 29/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

// Add a configuration group according to the parameters provided by the user
class AddConfigGroupViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pickview: UIView!
    @IBOutlet var basetable: UIView!
    
    @IBOutlet var name: UITextField!
    @IBOutlet var descrip: UITextField!
    @IBOutlet var datastore: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var datastorePick: UIPickerView!
    
    var pick = ""
    
    var singleDatastoreVersionRef: String = "" // Store chosen datastore version
    var singleDatastoreTypeRef: String = "" // Store chosen datastore type
    
    let datastoreP: [String] = ["MySQL -5.7-8", "PostgreSQL -9.6-11"]
    let datastoreTypeId:[String] = ["MySQL", "PostgreSQL"]
    let datastoreVersionId:[String] = ["5.7-8", "9.6-11"]
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Configuration Group"
        
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        datastorePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        datastorePick.hidden = true
        datastore.inputView = datastorePick
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "ConfigGroupCreated", object: nil)
        
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
        if pickerView == datastorePick {
            countrows = datastoreP.count
        }
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == datastorePick {
            self.view.endEditing(true)
            let titleRow = datastoreP[row]
            return titleRow
            
        }
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datastorePick {
            self.datastore.text = self.datastoreP[row]
            singleDatastoreVersionRef = self.datastoreVersionId[row]
            singleDatastoreTypeRef = self.datastoreTypeId[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.datastore){
            name.resignFirstResponder()
            descrip.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            datastorePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "datastore"
            
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
        if (pick == "datastore"){
            datastore.resignFirstResponder()
            basetable.userInteractionEnabled = true
            datastorePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "datastore"){
            datastore.text = ""
            datastorePick.hidden = true
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
        if pickerView == datastorePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.datastoreP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        return pickerLabel
    }
    
    
    func createClick() {
        
        // Ensure configuration name parameter is not empty
        guard let nametext = self.name.text where !nametext.isEmpty else{
            PromptErrorMessage("Configuration group name cannot be empty", viewController: self)
            return
        }
        
        // Ensure datastore parameter is not empty
        guard let datastoretext = self.datastore.text where !datastoretext.isEmpty else{
            PromptErrorMessage("Datastore cannot be empty", viewController: self)
            return
        }
        var descripText = "None"
        if descrip.text?.isEmpty == false {
            descripText = descrip.text!
        }
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
            
            // Request Openstack to add a new configuration group with provided parameters
            NeCTAREngine.sharedEngine.createConfigurationGroup(user.databaseServiceURL, name: nametext, descrip: descripText, datastoreVersion: self.singleDatastoreVersionRef, datastoreType: self.singleDatastoreTypeRef, token: user.tokenID).then{(json) -> Void in
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("ConfigGroupCreated", obj: "created")
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
                        errorMessage = "Configuration group information is incorrect.\(err)"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
        }
        
        
        
    }
    
}
