//
//  VolumesViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/16.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import SnapKit

class AboutViewController: BaseViewController {

    @IBOutlet var unimelbLogo: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.snp_makeConstraints{
            (make) -> Void in
            make.width.equalTo(Common.screenWidth)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToUnimelbWeb))
        self.unimelbLogo.addGestureRecognizer(tapGesture)
        unimelbLogo.userInteractionEnabled = true

    }
    // direct to nectar official website if nectar clicked
    @IBAction func goToNectarWeb(sender: AnyObject) {
        let url = NSURL(string: "https://nectar.org.au")!
        let webVC = WebViewController(request: url)
        self.navigationController?.pushViewController(webVC, animated: true)
            }
    // go to unimelb official website
    func goToUnimelbWeb(gesture: UIGestureRecognizer) {
        let url = NSURL(string: "http://www.unimelb.edu.au/")!
        let webVC = WebViewController(request: url)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
}
