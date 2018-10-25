//
//  ResizeVolumeForDatabaseIns.swift
//  NeCTARClient
//
//  Created by Qi Qi on 30/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

// Resize the volume size for a database instance according to the parameters provided by the user
class ResizeVolumeForDatabaseIns: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    //    var refreshControl: UIRefreshControl!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pickview: UIView!
    @IBOutlet var basetable: UIView!

    @IBOutlet var volumeSize: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var volumeSizePick: UIPickerView!

    var singleVolumeSizeRef: String = ""
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    var pick = ""
    var instanceId = ""
    
    var volumeSizeP: [String] = []
    
    func commonInit() {
        //Request the amount of available volume size
        volumeSizeP = DatabaseInstanceService.sharedService.unusedVolumeSize
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.navigationItem.title = "Resize Volume"
        
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        commonInit()
        
        volumeSizePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        volumeSizePick.hidden = true
        volumeSize.inputView = volumeSizePick
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "VolumeSizeEdited", object: nil)
        
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
        if pickerView == volumeSizePick {
            countrows = volumeSizeP.count
        }
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == volumeSizePick {
            self.view.endEditing(true)
            let titleRow = volumeSizeP[row]
            return titleRow
        }
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == volumeSizePick {
            self.volumeSize.text = self.volumeSizeP[row]
            singleVolumeSizeRef = self.volumeSizeP[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.volumeSize){
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            volumeSizePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "volumeSize"
            
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
        if pickerView == volumeSizePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.volumeSizeP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        return pickerLabel
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        self.view.endEditing(true)
        if (pick == "volumeSize"){
            volumeSize.resignFirstResponder()
            basetable.userInteractionEnabled = true
            volumeSizePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "volumeSize"){
            volumeSize.text = ""
            volumeSizePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    func createClick() {

        guard let volumeSizetext = self.volumeSize.text where !volumeSizetext.isEmpty else{
            PromptErrorMessage("Volume size cannot be empty", viewController: self)
            return
        }
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
                
                NeCTAREngine.sharedEngine.resizeDatabaseInstanceVolume(user.databaseServiceURL, instanceId: self.instanceId, newSize: Int(self.singleVolumeSizeRef)!, token: user.tokenID).then{
                    
                    (json) -> Void in
                    print(json)
                    
                    let msg = "Please refresh."
                    let alert = UIAlertController(title: "Edit Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                        self.postNotification("VolumeSizeEdited", obj: "edited")
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
                            //errorMessage = "Router information is incorrect."
                            errorMessage = "\(err)"
                        }
                        PromptErrorMessage(errorMessage, viewController: self)
                }
            
        }
        
        
        
    }
    
}

