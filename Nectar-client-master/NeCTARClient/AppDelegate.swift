//
//  AppDelegate.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/7/27.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        determineFrontPage()

        return true
    }
    
    func determineFrontPage () {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let guideSkiped = userDefaults.boolForKey("guide_skiped")
        
        if !guideSkiped {
            let guideVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Guide") as! GuideViewController
            let navGuideVC = UINavigationController(rootViewController: guideVC)
            navGuideVC.setNavigationBarHidden(true, animated: false)
            self.window?.rootViewController = navGuideVC
            userDefaults.setBool(true, forKey: "guide_skiped")
            userDefaults.synchronize()

        } else {
            gotoLoginVC()
        }
    }
    
    func gotoMainVC() {
        let entryPointOfMain = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.window?.rootViewController = entryPointOfMain
    }
    
    func gotoLoginVC() {
        let loginVC = UIStoryboard(name: "LoginStoryboard", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        let navLoginVC = UINavigationController(rootViewController: loginVC)
        navLoginVC.setNavigationBarHidden(true, animated: false)
        loginVC.postLoginAction = { userJSON in
            UserService.sharedService.handleLoginResponse(userJSON)
            self.gotoMainVC()
        }

        self.window?.rootViewController = navLoginVC
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

