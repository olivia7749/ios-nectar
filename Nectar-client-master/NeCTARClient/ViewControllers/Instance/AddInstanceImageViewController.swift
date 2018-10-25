//
//  AddInstanceViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/20.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

class AddInstanceImageViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var name: UITextField!
    
    @IBOutlet var pickview: UIView!
    @IBOutlet var basetable: UIView!
    @IBOutlet var flavor: UITextField!
    @IBOutlet var instanceCount: UITextField!
    @IBOutlet var imageName: UITextField!
    @IBOutlet var key: UITextField!
    @IBOutlet var security: UITextField!
    @IBOutlet var azone: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!

    @IBOutlet var add: UIButton!
    @IBOutlet var keyPick: UIPickerView!
    @IBOutlet var flavorPick: UIPickerView!
    @IBOutlet var imagePick: UIPickerView!
    @IBOutlet var azonePick: UIPickerView!
    var pick = ""
    
    var previous = ""
    var previousone = ""
    var now = ""
    var nowid = ""
    
    @IBOutlet var securityPick: UIPickerView!
    
    var azoneP: [String] = ["", "(Any availability zone)"]
    
    var imageP: [String] = [""]
    var flavorP: [String] = [""]
    var keyP: [String] = [""]
    var securityP: [String] = [""]
    
    var imageRef: [String] = [""]
    var flavorRef: [String] = [""]
    var securityId:[String] = [""]
    
    
    var singleImageRef: String = ""
    var singleFlavorRef: String = ""
    var singleSecurityId: [String] = []
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    
    
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
        for one in AZoneService.sharedService.azones{
            if one.state {
                azoneP.append(one.name)
            }
        }
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "New Instance"
        
//        let btn1=UIButton(frame: CGRectMake(0, 0, 60, 30))
//        btn1.setTitle("Create", forState: UIControlState.Normal)
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        commonInit()
        
        imagePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        flavorPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        keyPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        securityPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        azonePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        
        imagePick.hidden = true
        flavorPick.hidden = true
        keyPick.hidden = true
        securityPick.hidden = true
        azonePick.hidden = true
        
        imageName.inputView = imagePick
        flavor.inputView = flavorPick
        key.inputView = keyPick
        security.inputView = securityPick
        azone.inputView = azonePick
        
        done.hidden = true
        cancel.hidden = true
        add.hidden = true
        
        done.enabled = true
        cancel.enabled = true
        add.enabled = true
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "InstanceCreated", object: nil)
        
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
        if pickerView == imagePick {
            countrows = imageP.count
        } else if pickerView == flavorPick {
            countrows = flavorP.count
        } else if pickerView == keyPick {
            countrows = keyP.count
        } else if pickerView == securityPick {
            countrows = securityP.count
        } else if pickerView == azonePick {
            countrows = azoneP.count
        }
        
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == imagePick {
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
        } else if pickerView == azonePick{
            self.view.endEditing(true)
            let titleRow = azoneP[row]
            
            return titleRow
        }
        
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == imagePick {
            self.imageName.text = self.imageP[row]
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
        } else if pickerView == azonePick {
            self.azone.text = self.azoneP[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.imageName){
            name.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            imagePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            //create.hidden = true
            pick = "image"
            
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
            //create.hidden = true
            pick = "flavor"
            
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
            //create.hidden = true
            pick = "key"
            
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
            //create.hidden = true
            add.hidden = false
            pick = "security"
            
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
                textField.text = securityP[0]
            }
            return false
        } else if (textField == self.azone){
            name.resignFirstResponder()
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
        if (pick == "image"){
            imageName.resignFirstResponder()
            basetable.userInteractionEnabled = true
            imagePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "flavor"){
            flavor.resignFirstResponder()
            basetable.userInteractionEnabled = true
            flavorPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "key"){
            key.resignFirstResponder()
            basetable.userInteractionEnabled = true
            keyPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "security"){
            security.resignFirstResponder()
            self.security.text = self.security.text!
            previous = security.text!
            basetable.userInteractionEnabled = true
            securityPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            add.hidden = true
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
        if (pick == "image"){
            imageName.text = ""
            imagePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            
        } else if (pick == "flavor"){
            flavor.text = ""
            flavorPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            
        } else if (pick == "key"){
            key.text = ""
            keyPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "security"){
            security.text = ""
            previous = ""
            now = ""
            previousone = ""
            singleSecurityId = []
            securityPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            add.hidden = true
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
    @IBAction func addClick(sender: AnyObject) {
        if now != previousone && now != ""{
            security.text = previous + now  + ";"
            previous = security.text!
            previousone = now
            singleSecurityId.append(nowid)
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        if pickerView == imagePick {
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
        }else if pickerView == azonePick {
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
        guard let instancetext = self.name.text where !instancetext.isEmpty else{
            PromptErrorMessage("Instance name cannot be empty", viewController: self)
            return
        }
        guard let flavortext = self.flavor.text where !flavortext.isEmpty else{
            PromptErrorMessage("Flavor cannot be empty", viewController: self)
            return
        }
        guard let imagetext = self.imageName.text where !imagetext.isEmpty else{
            PromptErrorMessage("Image name cannot be empty", viewController: self)
            return
        }
        
        var defaultid = ""
        
        for (index, i) in securityP.enumerate() {
            if i == "default" {
                defaultid = securityId[index]
            }
        }
        
        let keytext = self.key.text
        
        var securitytext = self.security.text
        
        let azonetext = self.azone.text
        
        if securitytext == "" {
            securitytext = "default"
            singleSecurityId = [defaultid]

        }
        
        if !(securitytext?.containsString("default"))! {
            for (index, i) in singleSecurityId.enumerate() {
                if i == defaultid {
                    singleSecurityId.removeAtIndex(index)
                }
            }
        }

        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        
        print(instancetext)
        print(singleFlavorRef)
        print(singleImageRef)
        print(keytext)
        print(securitytext)
        print(Array(Set(singleSecurityId)))
        
        
        
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.createInstance(user.computeServiceURL, name: instancetext, flavor: singleFlavorRef.componentsSeparatedByString("/")[5], image: singleImageRef, key: keytext!, security: singleSecurityId, azone: azonetext!, token: user.tokenID).then{
                (json) -> Void in
                print(json)
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("InstanceCreated", obj: "created")
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
                        errorMessage = "Instance information is incorrect."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
        }
        
 
        
    }

}
