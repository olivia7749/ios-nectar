//
//  AddInstanceVolumeViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/28.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable

class AddInstanceVolumeViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var name: UITextField!
    
    @IBOutlet var basetable: UIView!
    @IBOutlet var flavor: UITextField!
    @IBOutlet var instanceCount: UITextField!
    @IBOutlet var volumeName: UITextField!
    @IBOutlet var key: UITextField!
    @IBOutlet var security: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var add: UIButton!
    @IBOutlet var create: UIButton!
    @IBOutlet var keyPick: UIPickerView!
    @IBOutlet var flavorPick: UIPickerView!
    @IBOutlet var volumePick: UIPickerView!
    var pick = ""
    var previous = ""
    var now = ""
    var nowid = ""
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var securityPick: UIPickerView!
    
    
    
    var imageP: [String] = []
    var flavorP: [String] = []
    var keyP: [String] = [""]
    var securityP: [String] = [""]
    
    var imageRef: [String] = []
    var flavorRef: [String] = []
    var securityId:[String] = [""]
    
    var singleImageRef: String = ""
    var singleFlavorRef: String = ""
    var singleSecurityId: [String] = []
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    
    func commonInit(){
        for one in ImageService.sharedService.images{
            imageP.append(one.name)
            imageRef.append(one.id)
        }
        for one in FlavorService.sharedService.falvors{
            flavorP.append(one.name)
            flavorRef.append(one.herf)
        }
        for one in KeyService.sharedService.keys{
            keyP.append(one.name)
        }
        for one in SecurityService.sharedService.securities{
            securityP.append(one.name)
            securityId.append(one.id)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Instance"
        
        commonInit()
        
        volumePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        flavorPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        keyPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        securityPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        
        volumePick.hidden = true
        flavorPick.hidden = true
        keyPick.hidden = true
        securityPick.hidden = true
        
        volumeName.inputView = volumePick
        flavor.inputView = flavorPick
        key.inputView = keyPick
        security.inputView = securityPick
        
        done.hidden = true
        cancel.hidden = true
        add.hidden = true
        create.hidden = false
        
        done.enabled = true
        cancel.enabled = true
        create.enabled = true
        add.enabled = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        //panGesture.addTarget(self, action: #selector(pan(_:)))
        //self.view.addGestureRecognizer(panGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "InstanceCreated", object: nil)
        
        
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
        if pickerView == volumePick {
            countrows = imageP.count
        } else if pickerView == flavorPick {
            countrows = flavorP.count
        } else if pickerView == keyPick {
            countrows = keyP.count
        } else if pickerView == securityPick {
            countrows = securityP.count
        }
        
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == volumePick {
            self.view.endEditing(true)
            
            let titleRow = imageP[row]
            
            return titleRow
            
        } else if pickerView == flavorPick{
            self.view.endEditing(true)
            let titleRow = flavorP[row]
            
            return titleRow
        } else if pickerView == keyPick{
            self.view.endEditing(true)
            let titleRow = keyP[row]
            
            return titleRow
        } else if pickerView == securityPick{
            self.view.endEditing(true)
            let titleRow = securityP[row]
            
            return titleRow
        }
        
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == volumePick {
            self.volumeName.text = self.imageP[row]
            singleImageRef = self.imageRef[row]
        } else if pickerView == flavorPick {
            self.flavor.text = self.flavorP[row]
            singleFlavorRef = self.flavorRef[row]
        } else if pickerView == keyPick {
            self.key.text = self.keyP[row]
        } else if pickerView == securityPick {
            self.security.text = previous
            now = self.securityP[row]
            nowid = self.securityId[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.volumeName){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            volumePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            create.hidden = true
            pick = "volume"
            if textField.text!.isEmpty {
                textField.text = imageP[0]
                singleImageRef = self.imageRef[0]
            }
            return false
            
        } else if (textField == self.flavor){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            flavorPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            create.hidden = true
            pick = "flavor"
            if textField.text!.isEmpty {
                textField.text = flavorP[0]
                singleFlavorRef = self.flavorRef[0]
            }
            return false
            
        } else if (textField == self.key){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            keyPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            create.hidden = true
            pick = "key"
            if textField.text!.isEmpty {
                textField.text = keyP[0]
            }
            return false
        } else if (textField == self.security){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            securityPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            create.hidden = true
            add.hidden = false
            pick = "security"
            if textField.text!.isEmpty {
                textField.text = securityP[0]
            }
            return false
        } else {
            textField.endEditing(true)
            return true
        }
        
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        if (pick == "volume"){
            volumeName.resignFirstResponder()
            basetable.userInteractionEnabled = true
            volumePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            pick = ""
            
        } else if (pick == "flavor"){
            flavor.resignFirstResponder()
            basetable.userInteractionEnabled = true
            flavorPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            pick = ""
            
        } else if (pick == "key"){
            key.resignFirstResponder()
            basetable.userInteractionEnabled = true
            keyPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            pick = ""
        } else if (pick == "security"){
            security.resignFirstResponder()
            self.security.text = self.security.text!
            previous = security.text!
            basetable.userInteractionEnabled = true
            securityPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            add.hidden = true
            pick = ""
        }
        
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "volume"){
            volumePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            pick = ""
            
        } else if (pick == "flavor"){
            flavorPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            pick = ""
            
        } else if (pick == "key"){
            keyPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            pick = ""
        } else if (pick == "security"){
            security.text = ""
            previous = ""
            now = ""
            securityPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            create.hidden = false
            add.hidden = true
            pick = ""
        }
        
    }
    @IBAction func addClick(sender: AnyObject) {
        security.text = previous + now  + ";"
        singleSecurityId.append(nowid)
        previous = security.text!
        now = ""
        
        
        
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        if pickerView == volumePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.imageP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == flavorPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.flavorP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == keyPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.keyP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == securityPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.securityP[row]
            // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        
        return pickerLabel
    }
    
    
    @IBAction func createClick(sender: AnyObject) {
        
        print("!!!!!!!")
        guard let instancetext = self.name.text where !instancetext.isEmpty else{
            PromptErrorMessage("Instance name cannot be empty", viewController: self)
            return
        }
        guard let flavortext = self.flavor.text where !flavortext.isEmpty else{
            PromptErrorMessage("Flavor cannot be empty", viewController: self)
            return
        }
        guard let volumetext = self.volumeName.text where !volumetext.isEmpty else{
            PromptErrorMessage("Volume name cannot be empty", viewController: self)
            return
        }
        
        let keytext = self.key.text
        
        var securitytext = self.security.text
        
        if securitytext!.isEmpty || securitytext == ";"{
            
            securitytext = "default"
            
            for (index, i) in securityP.enumerate() {
                if i == "default" {
                    singleSecurityId.append(securityId[index])
                }
            }
        }
        
        self.indicator.startAnimating()
        self.scrollView.userInteractionEnabled = false
        
        
        
        print(instancetext)
        print(singleFlavorRef)
        print(singleImageRef)
        print(keytext)
        print(securitytext)
        print(singleSecurityId)
        
//        if let user = UserService.sharedService.user{
//            NeCTAREngine.sharedEngine.createInstance(user.computeServiceURL, name: instancetext, flavor: singleFlavorRef.componentsSeparatedByString("/")[5], image: singleImageRef, key: keytext!, security: singleSecurityId, token: user.tokenID).then{
//                (json) -> Void in
//                print(json)
//                
//                
//                
//                let msg = "Please refresh."
//                let alert = UIAlertController(title: " Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
//                    self.dismissViewControllerAnimated(false, completion: nil)
//                    self.postNotification("InstanceCreated", obj: "created")
//                }))
//                
//                
//                //self.performSegueWithIdentifier("test", sender: nil)
//                self.presentViewController(alert, animated: true, completion: nil)
//                
//                //
//                //self.navigationController?.popToRootViewControllerAnimated(true)
//                
//                
//                }.always{
//                    self.indicator.stopAnimating()
//                    self.scrollView.userInteractionEnabled = true
//                }.error{(err) -> Void in
//                    var errorMessage:String = "Action Failed."
//                    switch err {
//                    case NeCTAREngineError.CommonError(let msg):
//                        errorMessage = msg!
//                        
//                    default:
//                        errorMessage = "Instance information is incorrect."
//                    }
//                    PromptErrorMessage(errorMessage, viewController: self)
//            }
//        }
        
        
        
    }
    
}
