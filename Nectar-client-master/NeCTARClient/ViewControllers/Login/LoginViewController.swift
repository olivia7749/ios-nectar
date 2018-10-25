//
//  LoginViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/12.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import SwiftyJSON


class LoginViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tenantName: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var login: UIButton!
    @IBOutlet var eye: UIButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var remSwitch: UISwitch!
    
    var activeField: UITextField?
    var postLoginAction:((JSON)->())?
    var switchStatus: String?
    
    let myKeychainItemWrapper = KeychainItemWrapper(identifier: "Account_Number", accessGroup: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        if (NSUserDefaults.standardUserDefaults().valueForKey("remSwitch") as? String == "YES") {
            if (NSUserDefaults.standardUserDefaults().valueForKey("username") != nil) {
                username.text = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
                tenantName.text = NSUserDefaults.standardUserDefaults().valueForKey("tenantname") as? String
                password.text = myKeychainItemWrapper.objectForKey(kSecValueData) as? String
            }
        }
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func loginAction(sender: UIButton) {
        guard let tenantName = self.tenantName.text where !tenantName.isEmpty else{
            PromptErrorMessage("Tenant name cannot be empty", viewController: self)
            return
        }
        guard let username = self.username.text where !username.isEmpty else {
            PromptErrorMessage("Username cannot be empty", viewController: self)
            return
        }
        guard let password = self.password.text where !password.isEmpty else {
            PromptErrorMessage("Password cannot be empty", viewController: self)
            return
        }
        self.indicator.startAnimating()
        self.login.userInteractionEnabled = false
        NeCTAREngine.sharedEngine.login(tenantName, username: username, password: password).then{
            (json) -> Void in
            
            //Remember username, tenant name, password, and make passwored encrypted before being stored
            NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
            NSUserDefaults.standardUserDefaults().setValue(tenantName, forKey: "tenantname")
            
            if self.remSwitch.on == true {
                self.switchStatus = "YES"
            } else {
                self.switchStatus = "NO"
            }
            NSUserDefaults.standardUserDefaults().setValue(self.switchStatus, forKey: "remSwitch")
            
            self.myKeychainItemWrapper.setObject(password, forKey: kSecValueData)
            
            self.postLoginAction?(json)
            print(json)
            print(UserService.sharedService.user?.computeServiceURL)
            print(UserService.sharedService.user?.tokenID)
            
            }.always{
                self.indicator.stopAnimating()
                self.login.userInteractionEnabled = true
            }.error{(err) -> Void in
                var errorMessage:String = "Action Failed."
                switch err {
                case NeCTAREngineError.CommonError(let msg):
                    errorMessage = msg!
                    
                default:
                    errorMessage = "User information is incorrect."
                }
                PromptErrorMessage(errorMessage, viewController: self)
        }
        
    }
    
    @IBAction func passwordVisible(sender: UIButton) {
        let visble = self.password.secureTextEntry
        self.password.secureTextEntry = !visble
    }
    
    @IBAction func passwordRemember(sender: UISwitch) {
        if remSwitch.on == false {
            self.switchStatus = "NO"
        } else {
            self.switchStatus = "YES"
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
