//
//  ImportKeyViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/26.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImportKeyViewController: BaseViewController{
    
    @IBOutlet var name: UITextField!
    @IBOutlet var key: UITextView!
    
    @IBOutlet var scrollView: UIScrollView!
    var activeField: UITextField?
    var hudParentView = UIView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Import Key"
        
        let btn1=UIButton(frame: CGRectMake(0, 0, 60, 30))
        btn1.setTitle("Import", forState: UIControlState.Normal)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn1.addTarget(self, action:#selector(importKey),forControlEvents:.TouchUpInside)
        let item2=UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem=item2
        
        key.layer.borderColor = UIColor(red: 215/255.0, green: 215/255.0, blue:  215/255.0, alpha: 1.0).CGColor;
        key.layer.borderWidth = 0.6;
        key.layer.cornerRadius = 6;
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        hudParentView = self.view
        
        //panGesture.addTarget(self, action: #selector(pan(_:)))
        //self.view.addGestureRecognizer(panGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(returnBack), name: "KeyImport", object: nil)
        
        
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
    
    func textViewShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    
    func tap(sender:AnyObject) {
        self.view.endEditing(true)
    }
    
    func importKey() {
        
        guard let nametext = self.name.text where !nametext.isEmpty else{
            PromptErrorMessage("Key pair name cannot be empty", viewController: self)
            return
        }
        guard let keytext = self.key.text where !keytext.isEmpty else{
            PromptErrorMessage("Public key cannot be empty", viewController: self)
            return
        }
        
        print(nametext)
        print(keytext)
        
        self.scrollView.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)
        
        if let user = UserService.sharedService.user{
            NeCTAREngine.sharedEngine.importKeypair(nametext, url: user.computeServiceURL, publicKey: keytext, token: user.tokenID).then{
                (json) -> Void in
                print(json)
                
                let msg = "Please refresh."
                let alert = UIAlertController(title: "Import Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    self.postNotification("KeyImport", obj: "import")
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
                        errorMessage = "Key information is incorrect."
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
        }
        
        
    }
    
}