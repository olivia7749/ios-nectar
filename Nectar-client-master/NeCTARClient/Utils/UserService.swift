//
//  UserService.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/4.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import SwiftyJSON


func loginRequired() {
    if UserService.sharedService.isLoggedIn {
        return
    }
    guard let rootViewController = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController else {return}
    let loginVC = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
    let navLoginVC = UINavigationController(rootViewController: loginVC)
    navLoginVC.setNavigationBarHidden(true, animated: false)
    loginVC.postLoginAction = { json in
        
        UserService.sharedService.handleLoginResponse(json)
        
        let entryPointOfMain = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = entryPointOfMain

        
    }
    rootViewController.presentViewController(navLoginVC, animated: true, completion: nil)
}

//func urlForService(service: String, json: JSON) -> String {
//    
//}

class UserService {
    
    static let sharedService = UserService()
    
    var user: User?
    
    func logout() {
        self.user = nil
    }
    
    func handleLoginResponse(json:JSON) {
        let user = User(json: json)
        if user == nil {
            let alertView = UIAlertController(title: nil, message: "Login failed please try again", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertView.addAction(cancelAction)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
        }
        self.user = user
    }

    var isLoggedIn:Bool {
        get {
            return (user != nil)
        }
    }
}