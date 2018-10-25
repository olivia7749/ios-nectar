//
//  CommonUsage.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/14.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import Foundation
import UIKit


struct Common {
    static let screenWidth = UIScreen.mainScreen().bounds.maxX
    static let screenHeight = UIScreen.mainScreen().bounds.maxY
    
//    static let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
}

func PromptErrorMessage(msg:String, viewController:UIViewController, callback:((UIAlertAction)->Void)?=nil) {
    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
        callback?(action)
    }))
    viewController.presentViewController(alert, animated: true, completion: nil)
}

func imageWithCaptureView(view: UIView) -> UIImage {
    
    let size = CGSizeMake(view.bounds.size.width, view.bounds.size.height)
    
    // open bitmap context
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    
    // get context
    let ctx = UIGraphicsGetCurrentContext()
    
    // render the layer to context
    view.layer.renderInContext(ctx!)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    // close context
    UIGraphicsEndImageContext()
    
    return image
}
