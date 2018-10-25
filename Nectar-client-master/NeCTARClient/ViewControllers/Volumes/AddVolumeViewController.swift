//
//  AddVolumeViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/5/4.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

class AddVolumeViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var name: UITextField!
    
    @IBOutlet var basetable: UIView!
    @IBOutlet var vdescription: UITextField!
    @IBOutlet var type: UITextField!
    @IBOutlet var size: UITextField!
    @IBOutlet var azone: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var typePick: UIPickerView!
    @IBOutlet var azonePick: UIPickerView!

    var pick = ""
    
    var azoneP: [String] = ["", "NCI","QRIScloud","intersect","melbourne-np", "melbourne-qh2","monash-01", "monash-02", "pawsey-01","sa", "tasmania", "tasmania-s"]
    var typeP:[String] = ["", "No volume type","sa","intersect", "NCI", "melbourne"]
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Volume"
        
//        let btn1=UIButton(frame: CGRectMake(0, 0, 60, 30))
//        btn1.setTitle("Create", forState: UIControlState.Normal)
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        typePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        azonePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        
        typePick.hidden = true
        azonePick.hidden = true
        
        type.inputView = typePick
        azone.inputView = azonePick
        
        done.hidden = true
        cancel.hidden = true
        
        done.enabled = true
        cancel.enabled = true
        
        type.text = typeP[0]
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "VolumeCreated", object: nil)
        
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
        if pickerView == typePick {
            countrows = typeP.count
        } else if pickerView == azonePick {
            countrows = azoneP.count
        }
        
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == typePick {
            self.view.endEditing(true)
            
            let titleRow = typeP[row]
            
            return titleRow
            
        } else if pickerView == azonePick{
            self.view.endEditing(true)
            let titleRow = azoneP[row]
            
            return titleRow
        }
        
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == typePick {
            self.type.text = self.typeP[row]
        } else if pickerView == azonePick {
            self.azone.text = self.azoneP[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.type){
            name.resignFirstResponder()
            vdescription.resignFirstResponder()
            size.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            typePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            //create.hidden = true
            pick = "type"
            
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
            
            if textField.text!.isEmpty {
                textField.text = typeP[0]
            }
            return false
            
        } else if (textField == self.azone){
            name.resignFirstResponder()
            vdescription.resignFirstResponder()
            size.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            azonePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            //create.hidden = true
            //add.hidden = false
            pick = "azone"
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 151, 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 151
            if let _ = activeField
            {
                if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
            }
            if textField.text!.isEmpty {
                textField.text = azoneP[0]
            }
            return false
        } else {
            textField.endEditing(true)
            return true
        }
        
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        self.view.endEditing(true)
        if (pick == "type"){
            type.resignFirstResponder()
            basetable.userInteractionEnabled = true
            typePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "azone"){
            azone.resignFirstResponder()
            basetable.userInteractionEnabled = true
            azonePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
        
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "type"){
            type.text = ""
            typePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            
        } else if (pick == "azone"){
            azone.text = ""
            azonePick.hidden = true
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
        if pickerView == typePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.typeP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == azonePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.azoneP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        
        return pickerLabel
    }
    
    
    func createClick() {
        
        print("!!!!!!!")
        guard let volumetext = self.name.text where !volumetext.isEmpty else{
            PromptErrorMessage("Volume name cannot be empty", viewController: self)
            return
        }
        guard let sizetext = self.size.text where !sizetext.isEmpty else{
            PromptErrorMessage("Size cannot be empty", viewController: self)
            return
        }
        guard let azonetext = self.azone.text where !azonetext.isEmpty else{
            PromptErrorMessage("Availability Zone cannot be empty", viewController: self)
            return
        }
        
        if Int(sizetext) < 1 {
            PromptErrorMessage("Size is invalid", viewController: self)
            return
        }
        
        let descriptiontext = self.vdescription.text
        
        let tpyetext = self.type.text
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        
        print(volumetext)
        print(sizetext)
        print(azonetext)
        print(descriptiontext)
        print(tpyetext)
        
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.createVolume(user.volumeV3ServiceURL, projectId: user.tenantID, name: volumetext, vdescription: descriptiontext!, type: tpyetext!, size: Int(sizetext)!,azone: azonetext, token: user.tokenID).then{
                (json) -> Void in
                print(json)
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("VolumeCreated", obj: "created")
                }))
                
                
                //self.performSegueWithIdentifier("test", sender: nil)
                self.presentViewController(alert, animated: true, completion: nil)
                
                //
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
                        errorMessage = "Volume information is incorrect."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
        }
        
        
        
    }
    
}

