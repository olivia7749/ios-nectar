//
//  EditImageViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/27.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable

class EditImageViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var basetable: UIView!
    
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    @IBOutlet var formatPick: UIPickerView!
    
    @IBOutlet var nameText: UITextField!
    
    @IBOutlet var formatText: UITextField!
    @IBOutlet var diskText: UITextField!
    
    @IBOutlet var ramText: UITextField!
    
    @IBOutlet var isPublicText: UISegmentedControl!
    
    @IBOutlet var isProtectedText: UISegmentedControl!
    
    @IBOutlet var save: UIButton!
    
    var name: String = ""
    var id: String = ""
    var disk: String = ""
    var ram: String = ""
    var isPublic: String = ""
    var isProtected: String = ""
    var format: String = ""
    

    @IBOutlet var indicator: UIActivityIndicatorView!
    
    
    var formatP: [String] = ["AKI - Amazon Kernel Image", "AMI - Amazon Machine Image", "ARI - Amazon Ramdisk Image", "ISO - Optical Disk Image", "QCOW2 - QEMU Emulator", "Raw", "VDI - Virtual Disk Image", "VHD - Virtual Hard Disk", "VMDK - Virtual Machine Disk"]
    
    
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Edit Image"
        self.navigationItem.rightBarButtonItem = nil
        
        formatPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)

        
        formatPick.hidden = true
 
        formatText.inputView = formatPick

        
        done.hidden = true
        cancel.hidden = true
        save.hidden = false
        
        done.enabled = true
        cancel.enabled = true
        save.enabled = true
        
        nameText.text = name
        diskText.text = disk
        ramText.text = ram
        
        for (index, one) in formatP.enumerate()  {
            if one.hasPrefix(format.uppercaseString) {
                formatText.text = formatP[index]
                formatPick.selectRow(index, inComponent: 0, animated: true)
            }
        }
        
        if isPublic == "Yes" {
            isPublicText.selectedSegmentIndex = 0
        } else {
            isPublicText.selectedSegmentIndex = 1
        }
        
        if isProtected == "Yes" {
            isProtectedText.selectedSegmentIndex = 0
        } else {
            isProtectedText.selectedSegmentIndex = 1
        }
        
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "ImageSave", object: nil)
        
        
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

        countrows = formatP.count
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        let titleRow = formatP[row]
        
        return titleRow
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        self.formatText.text = self.formatP[row]
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (textField == self.formatText){
            nameText.resignFirstResponder()
            diskText.resignFirstResponder()
            ramText.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            formatPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            save.hidden = true
            if textField.text!.isEmpty {
                textField.text = formatP[0]
            }
            return false
        } else {
            textField.endEditing(true)
            return true
        }
        
        
        
    }
    @IBAction func doneClick(sender: AnyObject) {
        formatText.resignFirstResponder()
        basetable.userInteractionEnabled = true
        formatPick.hidden = true
        done.hidden = true
        cancel.hidden = true
        save.hidden = false
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        formatPick.hidden = true
        basetable.userInteractionEnabled = true
        done.hidden = true
        cancel.hidden = true
        save.hidden = false
        
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        pickerLabel.text = self.formatP[row]
        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.Center
        
        return pickerLabel
    }
    
    
    @IBAction func saveClick(sender: AnyObject) {
        
        print("!!!!!!!")
        guard let nametext = self.nameText.text where !nametext.isEmpty else{
            PromptErrorMessage("Image name cannot be empty", viewController: self)
            return
        }
        guard let formattext = self.formatText.text where !formattext.isEmpty else{
            PromptErrorMessage("Format cannot be empty", viewController: self)
            return
        }
        guard let disktext = self.diskText.text where !disktext.isEmpty else{
            PromptErrorMessage("Minimum disk cannot be empty", viewController: self)
            return
        }
        guard let ramtext = self.ramText.text where !ramtext.isEmpty else{
            PromptErrorMessage("Minimum ram cannot be empty", viewController: self)
            return
        }

        
        if Int(disktext) < 0 {
            PromptErrorMessage("Minimum disk is invalid", viewController: self)
            return
        }
        if Int(ramtext) < 0  {
            PromptErrorMessage("Minimum ram is invalid", viewController: self)
            return
        }
        
        self.indicator.startAnimating()
        self.scrollView.userInteractionEnabled = false
        
        
        
        print(nametext)
        print(formattext)
        print(disktext)
        print(ramtext)
        print(isPublicText.selectedSegmentIndex)
        print(isProtectedText.selectedSegmentIndex)
        
//        var realFormat = ""
//        var realPublic = ""
//        var realProtected = ""
//        
//        realFormat = formattext.componentsSeparatedByString(" - ")[0].lowercaseString
//        
//        if isPublicText.selectedSegmentIndex == 0 {
//            realPublic = "public"
//        } else {
//            realPublic = "private"
//        }
//        
//        if isProtectedText.selectedSegmentIndex == 0{
//            realProtected = "true"
//        } else {
//            realProtected = "false"
//        }
        
        
//        if let user = UserService.sharedService.user{
//            NeCTAREngine.sharedEngine.updateImage(user.imageServiceURL, imageId: id, name: nametext, format: realFormat, disk: disktext, ram: ramtext, isPublic: realPublic, isProtected: realProtected, token: user.tokenID).then{
//                (json) -> Void in
//                print(json)
//                
//                
//                
//                let msg = "Please refresh."
//                let alert = UIAlertController(title: " Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
//                    self.dismissViewControllerAnimated(false, completion: nil)
//                    self.postNotification("ImageSave", obj: "save")
//                }))
//                self.presentViewController(alert, animated: true, completion: nil)
//                
//                //self.navigationController?.popViewControllerAnimated(true)
//                //self.navigationController?.popToRootViewControllerAnimated(true)
//                
//                }.always{
//                    self.indicator.stopAnimating()
//                    self.scrollView.userInteractionEnabled = true
//                }.error{(err) -> Void in
//                    var errorMessage:String = "Action Failed."
//                    print(err)
//                    switch err {
//                    case NeCTAREngineError.CommonError(let msg):
//                        errorMessage = msg!
//                    default:
//                        errorMessage = "Image information is incorrect."
//                    }
//                    PromptErrorMessage(errorMessage, viewController: self)
//            }
//            
//        }
        
        
    }
    
}
