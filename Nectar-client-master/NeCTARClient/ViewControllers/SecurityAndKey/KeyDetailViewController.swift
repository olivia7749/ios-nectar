//
//  KeyDetailViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/20.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit

class KeyDetailViewController: BaseViewController {
    var key: Key?
    var index: Int?
    var panGesture = UIPanGestureRecognizer()
    

    @IBOutlet var name: UILabel!
    @IBOutlet var fingerprint: UILabel!
    @IBOutlet var created: UILabel!
    @IBOutlet var publicKey: UILabel!
    
    var centerOfBeginning: CGPoint!
    
    // load data
    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.computeServiceURL
            let token = user.tokenID
            
            NeCTAREngine.sharedEngine.keypairDetail(key!.name, url: url, token: token).then{(json2) -> Void in
                let creat = json2["keypair"]["created_at"].stringValue.stringByReplacingOccurrencesOfString("T", withString: " ").stringByReplacingOccurrencesOfString("Z", withString: "").componentsSeparatedByString(".")
                KeyService.sharedService.keys[self.index!].created = creat[0]

                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!

                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get all the key pair detail"
                        }
                    default:
                        errorMessage = "Fail to get all the key pair detail"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
 
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContent()
        
        panGesture.addTarget(self, action: #selector(pan(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        
    }
    
    
    func setContent() {
        
        name.text = key!.name
        fingerprint.text = key!.fingerprint
        created.text = key!.created
        publicKey.text = key!.publicKey
 
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

