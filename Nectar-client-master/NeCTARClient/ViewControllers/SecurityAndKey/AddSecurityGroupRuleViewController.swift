//
//  AddSecurityGroupRuleViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/20.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

class AddSecurityGroupRuleViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet var rule: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var direction: UITextField!
    

    @IBOutlet var minPort: UITextField!
    @IBOutlet var maxPort: UITextField!
    @IBOutlet var type: UITextField!
    @IBOutlet var basetable: UIView!

    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var rulePick: UIPickerView!

    var pick = ""
    @IBOutlet var directionPick: UIPickerView!
    
    @IBOutlet var typePick: UIPickerView!

   
    var ruleP: [String] = ["Custom UPD Rule","Custom TCP Rule"]
    var directionP: [String] = ["Egress","Ingress"]
    var typeP: [String] = ["0.0.0.0/0","::/0"]
    
    var securityId: String?

    
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Rule"
//        let btn1=UIButton(frame: CGRectMake(0, 0, 60, 30))
//        btn1.setTitle("Create", forState: UIControlState.Normal)
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        rulePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        directionPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        typePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        
        rulePick.hidden = true
        directionPick.hidden = true
        typePick.hidden = true
        
        rule.inputView = rulePick
        direction.inputView = directionPick
        type.inputView = typePick
        
        done.hidden = true
        cancel.hidden = true
        
        done.enabled = true
        cancel.enabled = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        
//        let tapper = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
//        tapper.cancelsTouchesInView = false
//        self.view.addGestureRecognizer(tapper)
        
        hudParentView = self.view
        
        //panGesture.addTarget(self, action: #selector(pan(_:)))
        //self.view.addGestureRecognizer(panGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "RuleCreated", object: nil)
        
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
        if pickerView == rulePick {
            countrows = ruleP.count
        } else if pickerView == directionPick {
            countrows = directionP.count
        } else if pickerView == typePick {
            countrows = typeP.count
        }
        
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == rulePick {
            self.view.endEditing(true)
            
            let titleRow = ruleP[row]
            
            return titleRow
            
        } else if pickerView == directionPick{
            self.view.endEditing(true)
            let titleRow = directionP[row]
            
            return titleRow
        } else if pickerView == typePick{
            self.view.endEditing(true)
            let titleRow = typeP[row]
            
            return titleRow
        }
        
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == rulePick {
            self.rule.text = self.ruleP[row]
        } else if pickerView == directionPick {
            self.direction.text = self.directionP[row]
        } else if pickerView == typePick {
            self.type.text = self.typeP[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField == self.rule){
            minPort.resignFirstResponder()
            maxPort.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            rulePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            //create.hidden = true
            pick = "rule"
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 193, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 193
            if let _ = activeField
            {
                if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
            }

            
            if textField.text!.isEmpty {
                textField.text = ruleP[0]
            }
            return false
        } else if (textField == self.direction){
            minPort.resignFirstResponder()
            maxPort.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            directionPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            //create.hidden = true
            pick = "direction"
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 193, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 193
            if let _ = activeField
            {
                if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
            }

            
            if textField.text!.isEmpty {
                textField.text = directionP[0]
            }
            return false
        } else if (textField == self.type){
            minPort.resignFirstResponder()
            maxPort.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            typePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            //create.hidden = true
            pick = "type"
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 193, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 193
            if let _ = activeField
            {
                if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
            }

            
            if textField.text!.isEmpty {
                textField.text = typeP[0]
            }
            return false
        } else {
            textField.endEditing(true)
            return true
        }
        
        
        
    }
    @IBAction func doneClick(sender: AnyObject) {
        self.view.endEditing(true)
        if (pick == "rule"){
            rule.resignFirstResponder()
            basetable.userInteractionEnabled = true
            rulePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -193, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "direction"){
            direction.resignFirstResponder()
            basetable.userInteractionEnabled = true
            directionPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -193, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "type"){
            type.resignFirstResponder()
            basetable.userInteractionEnabled = true
            typePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -193, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
        
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "rule"){
            rule.text = ""
            rulePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "direction"){
            direction.text = ""
            directionPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "type"){
            type.text = ""
            typePick.hidden = true
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
        if pickerView == rulePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.ruleP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == directionPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.directionP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == typePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.typeP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        
        return pickerLabel
    }
    
    
    func createClick() {
        
        print("!!!!!!!")
        guard let ruletext = self.rule.text where !ruletext.isEmpty else{
            PromptErrorMessage("Rule cannot be empty", viewController: self)
            return
        }
        guard let directiontext = self.direction.text where !directiontext.isEmpty else{
            PromptErrorMessage("Direction cannot be empty", viewController: self)
            return
        }
        guard let minporttext = self.minPort.text where !minporttext.isEmpty else{
            PromptErrorMessage("Min port cannot be empty", viewController: self)
            return
        }
        guard let maxporttext = self.maxPort.text where !maxporttext.isEmpty else{
            PromptErrorMessage("Max port cannot be empty", viewController: self)
            return
        }
        guard let typetext = self.type.text where !typetext.isEmpty else{
            PromptErrorMessage("CIDR cannot be empty", viewController: self)
            return
        }
        
        if Int(minporttext) < 1 || Int(minporttext) > 65535 {
            PromptErrorMessage("Min port is invalid", viewController: self)
            return
        }
        if Int(maxporttext) < 1 || Int(maxporttext) > 65535 {
            PromptErrorMessage("Max port is invalid", viewController: self)
            return
        }
        if Int(minporttext) > Int(maxporttext) {
            PromptErrorMessage("Min port and max port are invalid", viewController: self)
            return
        }
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        
        
        print(ruletext)
        print(directiontext)
        print(minporttext)
        print(maxporttext)
        print(typetext)
        print(securityId)
        var realType = ""
        var realRule = ""
        
        if ruletext == "Custom UPD Rule" {
            realRule = "udp"
        } else {
            realRule = "tcp"
        }
        
        if typetext == "0.0.0.0/0" {
            realType = "IPv4"
        } else {
            realType = "IPv6"
        }
        
        
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.addSecurityGroupsRule(user.networkServiceURL, securityGroupRuleID: securityId!, rule: realRule, direction: directiontext.lowercaseString, min: Int(minporttext)!, max: Int(maxporttext)!, type: realType, token: user.tokenID).then{
                (json) -> Void in
                print(json)
                
                
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("RuleCreated", obj: "created")
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
                //self.navigationController?.popViewControllerAnimated(true)
                //self.navigationController?.popToRootViewControllerAnimated(true)
                
                }.always{
                    self.scrollView.userInteractionEnabled = true
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!

                    default:
                        errorMessage = "Security group rule information is incorrect."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
        
        
    }
    
}

