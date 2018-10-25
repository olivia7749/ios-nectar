//
//  LeftViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/14.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import SnapKit

class LeftViewController: BaseViewController {
    
    @IBOutlet var tenantName: UILabel!
    @IBOutlet var userName: UILabel!

    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add constrains to make the menu weigth is appriate for the screen
        self.contentView.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(Common.screenWidth * 0.8)
        }
        self.tenantName.snp_makeConstraints{(make) -> Void in
            make.width.equalTo(Common.screenWidth * 0.8 - 80 )
        }
        self.userName.snp_makeConstraints{(make) -> Void in
            make.width.equalTo(Common.screenWidth * 0.8 - 80)
        }
        
        tenantName.text = UserService.sharedService.user?.tenantName
        userName.text = UserService.sharedService.user?.username
    }
    
    @IBAction func toOverView(sender: AnyObject) {
        turnToOtherPage("Overview")
    }
    
    @IBAction func toInstance(sender: AnyObject) {
        turnToOtherPage("Instance")
    }
    
    @IBAction func toAbout(sender: AnyObject) {
        turnToOtherPage("About")
    }
    
    @IBAction func toVolumes(sender: AnyObject) {
        turnToOtherPage("Volumes")
    }

    @IBAction func toImage(sender: AnyObject) {
        turnToOtherPage("Images")
    }

    @IBAction func toSecurity(sender: AnyObject) {
        turnToOtherPage("Access & Security")
    }
    
    @IBAction func logout(sender: AnyObject) {
        UserService.sharedService.logout()
        loginRequired ()
    }
    
    @IBAction func toRouters(sender: AnyObject) {
        turnToOtherPage("Routers")
    }
    
    @IBAction func toFloatingIPs(sender: AnyObject){
        turnToOtherPage("Floating IPs")
    }
    
    @IBAction func toContainers(sender: AnyObject){
        turnToOtherPage("Containers")
    }
    
    @IBAction func toNetworks(sender: AnyObject){
        turnToOtherPage("Networks")
    }
    
    @IBAction func toDatabaseInstances(sender: AnyObject){
        turnToOtherPage("Database Instances")
    }
    
    @IBAction func toOrchestration(sender: AnyObject){
        turnToOtherPage("Orchestration")
    }
    
    
    func turnToOtherPage (title: String) {
        
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
        viewController.homeViewController.titleOfOtherPages = title
        if(title != "Overview"){
            viewController.homeViewController.performSegueWithIdentifier("showOtherPages", sender: self)
        }
        viewController.showHome()
    }
}
