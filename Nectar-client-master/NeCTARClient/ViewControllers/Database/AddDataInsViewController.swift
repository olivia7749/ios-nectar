//
//  AddDatabaseInstanceViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 28/9/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

// Attach a database instance according to the parameters provided by the user
class AddDataInsViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    //    var refreshControl: UIRefreshControl!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pickview: UIView!
    @IBOutlet var basetable: UIView!
    
    @IBOutlet var instanceName: UITextField!
    @IBOutlet var lacality: UITextField!
    @IBOutlet var datastore: UITextField!
    @IBOutlet var volumeSize: UITextField!
    @IBOutlet var availabZone: UITextField!
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var done: UIButton!
    
    @IBOutlet var lacalityPick: UIPickerView!
    @IBOutlet var datastorePick: UIPickerView!
    @IBOutlet var volumeSizePick: UIPickerView!
    @IBOutlet var zonePick: UIPickerView!
    
    var singleDatastoreVersionRef: String = ""
    var singleDatastoreTypeRef: String = ""
    var singleVolumeSizeRef: String = ""
    var singleLacalityRef: String = ""
    var singleaZoneRef: String = ""
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    var pick = ""
    
    let lacalityP: [String] = ["None","affinity","anti-affinity"]
    let datastoreP: [String] = ["MySQL -5.7-8", "PostgreSQL -9.6-11"]
    let datastoreTypeId:[String] = ["MySQL", "PostgreSQL"]
    let datastoreVersionId:[String] = ["5.7-8", "9.6-11"]
    var volumeSizeP: [String] = []
    var zoneP: [String] = []
    
    
    //    var singleDatastoreVersionRef: String = ""
    //    var singleDatastoreTypeRef: String = ""
    //    var singleVolumeSizeRef: String = ""
    //    var singleLacalityRef: String = ""
    //
    //    var panGesture = UIPanGestureRecognizer()
    //    var activeField: UITextField?
    //    var hudParentView = UIView()
    
    
    
    func commonInit() {
        volumeSizeP = DatabaseInstanceService.sharedService.unusedVolumeSize
        for aZone in AvailabZoneService.sharedService.availabZones {
            zoneP.append(aZone.name)
        }
        //print("unusedSize\(volumeSizeP)")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.navigationItem.title = "New Instance"
        
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        commonInit()
        
        
        lacalityPick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        datastorePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        volumeSizePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        zonePick.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue:  245/255.0, alpha: 1.0)
        
        lacalityPick.hidden = true
        datastorePick.hidden = true
        volumeSizePick.hidden = true
        zonePick.hidden = true
        
        lacality.inputView = lacalityPick
        datastore.inputView = datastorePick
        volumeSize.inputView = volumeSizePick
        availabZone.inputView = zonePick
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "InstanceCreated", object: nil)
        
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneClick(_:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        
    }
    //    func refresh(sender:AnyObject) {
    //        // Code to refresh table view
    //        self.volumeSizeP = []
    //        commonInit()
    //    }
    
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
        if pickerView == lacalityPick {
            countrows = lacalityP.count
        } else if pickerView == datastorePick {
            countrows = datastoreP.count
        } else if pickerView == volumeSizePick {
            countrows = volumeSizeP.count
        } else if pickerView == zonePick {
            countrows = zoneP.count
        }
        return countrows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == lacalityPick {
            self.view.endEditing(true)
            let titleRow = lacalityP[row]
            return titleRow
        } else if pickerView == datastorePick {
            self.view.endEditing(true)
            let titleRow = datastoreP[row]
            return titleRow
        } else if pickerView == volumeSizePick {
            self.view.endEditing(true)
            let titleRow = volumeSizeP[row]
            return titleRow
        } else if pickerView == zonePick {
            self.view.endEditing(true)
            let titleRow = zoneP[row]
            return titleRow
        }
        return ""
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == lacalityPick {
            self.lacality.text = self.lacalityP[row]
            singleLacalityRef = self.lacalityP[row]
        } else if pickerView == datastorePick {
            self.datastore.text = self.datastoreP[row]
            singleDatastoreTypeRef = self.datastoreTypeId[row]
            singleDatastoreVersionRef = self.datastoreVersionId[row]
        } else if pickerView == volumeSizePick {
            self.volumeSize.text = self.volumeSizeP[row]
            singleVolumeSizeRef = self.volumeSizeP[row]
        } else if pickerView == zonePick {
            self.availabZone.text = self.zoneP[row]
            singleaZoneRef = self.zoneP[row]
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        if (textField == self.lacality){
            instanceName.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            lacalityPick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "lacality"
            
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
            
            //            if textField.text!.isEmpty {
            //                textField.text = adminStateP[1]
            //                singleAdminStateRef = self.adminStateId[1]
            //            }
            return false
            
        } else if (textField == self.datastore){
            instanceName.resignFirstResponder()
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
            //            if textField.text!.isEmpty {
            //                textField.text = "No external network"
            //                singleExternalNetworkRef = "null"
            //            }
            return false
            
        } else if (textField == self.volumeSize){
            instanceName.resignFirstResponder()
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
            //            if textField.text!.isEmpty {
            //                textField.text = "No external network"
            //                singleExternalNetworkRef = "null"
            //            }
            return false
            
        } else if (textField == self.availabZone){
            instanceName.resignFirstResponder()
            textField.endEditing(true)
            basetable.userInteractionEnabled = false
            zonePick.hidden = false
            done.hidden = false
            cancel.hidden = false
            pick = "zone"
            
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
            //            if textField.text!.isEmpty {
            //                textField.text = "No external network"
            //                singleExternalNetworkRef = "null"
            //            }
            return false
            
        } else {
            textField.endEditing(true)
            return true
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        
        let pickerLabel = UILabel()
        if pickerView == lacalityPick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.lacalityP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == datastorePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.datastoreP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == volumeSizePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.volumeSizeP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        } else if pickerView == zonePick {
            pickerLabel.textColor = UIColor.blackColor()
            pickerLabel.text = self.zoneP[row]
            pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15) // In this use your custom font
            pickerLabel.textAlignment = NSTextAlignment.Center
        }
        return pickerLabel
    }
    
    @IBAction func doneClick(sender: AnyObject) {
        self.view.endEditing(true)
        if (pick == "lacality"){
            lacality.resignFirstResponder()
            basetable.userInteractionEnabled = true
            lacalityPick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "datastore"){
            datastore.resignFirstResponder()
            basetable.userInteractionEnabled = true
            datastorePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "volumeSize"){
            volumeSize.resignFirstResponder()
            basetable.userInteractionEnabled = true
            volumeSizePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        } else if (pick == "zone"){
            availabZone.resignFirstResponder()
            basetable.userInteractionEnabled = true
            zonePick.hidden = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
        }
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        if (pick == "lacality"){
            lacality.text = ""
            lacalityPick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        } else if (pick == "datastore"){
            datastore.text = ""
            datastorePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        } else if (pick == "volumeSize"){
            volumeSize.text = ""
            volumeSizePick.hidden = true
            basetable.userInteractionEnabled = true
            done.hidden = true
            cancel.hidden = true
            pick = ""
            
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -151, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        } else if (pick == "zone"){
            availabZone.text = ""
            zonePick.hidden = true
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
        
        guard let instanceNametext = self.instanceName.text where !instanceNametext.isEmpty else{
            PromptErrorMessage("Instance name cannot be empty", viewController: self)
            return
        }
        guard let datastoretext = self.datastore.text where !datastoretext.isEmpty else{
            PromptErrorMessage("Datastore cannot be empty", viewController: self)
            return
        }
        guard let volumeSizetext = self.volumeSize.text where !volumeSizetext.isEmpty else{
            PromptErrorMessage("Volume size cannot be empty", viewController: self)
            return
        }
        guard let zonetext = self.availabZone.text where !zonetext.isEmpty else{
            PromptErrorMessage("Availability zone cannot be empty", viewController: self)
            return
        }
        
        if ((self.lacality.text?.isEmpty) == true) {
            singleLacalityRef = "None"
        }
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
            
            NeCTAREngine.sharedEngine.listDatabaseFlavors(user.databaseServiceURL, token: user.tokenID).then{(json0) -> Void in
                let flavorArray = json0["flavors"].arrayValue
                let flavorRef = flavorArray[0]["links"][0]["href"].stringValue
                print("flavorRef\(flavorRef)")
                
                NeCTAREngine.sharedEngine.createDatabaseinstance(user.databaseServiceURL, instanceName: instanceNametext, lacality: self.singleLacalityRef, datastoreVersion: self.singleDatastoreVersionRef, datastoreType: self.singleDatastoreTypeRef,flavorRef: flavorRef, volumeSize: self.singleVolumeSizeRef,availableZone: self.singleaZoneRef, token: user.tokenID).then{
                    
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
                            //errorMessage = "Router information is incorrect."
                            errorMessage = "\(err)"
                        }
                        PromptErrorMessage(errorMessage, viewController: self)
                }
                }.error{(err) -> Void in
                    
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                        
                    default:
                        //errorMessage = "Router information is incorrect."
                        errorMessage = "Flavor \(err)"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
        }
        
        
        
    }
    
}
