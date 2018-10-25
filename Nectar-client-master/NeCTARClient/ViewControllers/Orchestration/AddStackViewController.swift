//
//  AddStackViewController.swift
//  NeCTARClient
//
//  Created by Qi Qi on 3/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit
import IBAnimatable
import MBProgressHUD

class AddStackViewController: BaseViewController, UIPickerViewDelegate, UITextFieldDelegate{
    
    
    @IBOutlet var scrollView: UIScrollView!
    //    @IBOutlet var name: UITextField!
    //    @IBOutlet var descrip: UITextField!
    //
    //    var instanceId: String = ""
    //    var instanceName: String = ""
    
    
    var panGesture = UIPanGestureRecognizer()
    var activeField: UITextField?
    var hudParentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Stack"
        
        let btn1=UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn1.setImage(UIImage(named: "makeSure"), forState: UIControlState.Normal)
        btn1.setImage(UIImage(named: "makeSureGrey"), forState: UIControlState.Highlighted)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn1.addTarget(self, action:#selector(createClick),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        hudParentView = self.view
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "Stack created", object: nil)
        
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
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
    
    
    func createClick() {
        
        //        guard let nametext = self.name.text where !nametext.isEmpty else{
        //            PromptErrorMessage("Object name cannot be empty", viewController: self)
        //            return
        //        }
        //
        //        let descriptext = self.descrip.text
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
            
            NeCTAREngine.sharedEngine.createStack(user.orchestrationServiceURL,tenantId: user.tenantID, token: user.tokenID).then{
                //            NeCTAREngine.sharedEngine.createBackup(user.databaseServiceURL, name: nametext, instanceId: self.instanceId, descrip: descriptext!, token: user.tokenID).then{
                (json) -> Void in
                print(json)
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Create Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("Stack created", obj: "Created")
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                }.always{
                    self.scrollView.userInteractionEnabled = true
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }.error{(err) -> Void in
                    
//                    var errorMessage:String = "Action Failed."
//                    switch err {
//                    case NeCTAREngineError.CommonError(let msg):
//                        errorMessage = msg!
//                        
//                    default:
//                        errorMessage = "Stack information is incorrect\(err)."
//                        //errorMessage = "\(err)"
//                    }
                    var errorMessage: String = "\(err)"
                    print(errorMessage)
                    
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            
            
        }
        
    }
    
}
