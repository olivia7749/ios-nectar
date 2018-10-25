//
//  WebViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/10/4.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import MBProgressHUD

class WebViewController: UIViewController, UIWebViewDelegate {

    private let requestURL:NSURL
    
    @IBOutlet weak var webView: UIWebView!
    
    init(request:NSURL) {
        self.requestURL = request
        super.init(nibName: "WebViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.requestURL = NSURL(string: "http://www.yoflea.com.au")!
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        
        let closeButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(closeButtonOnTouch))
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let req = NSURLRequest(URL: self.requestURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 10)
        self.webView.loadRequest(req)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonOnTouch(sender: AnyObject) {
        self.webView.goBack()
    }
    
    @IBAction func forwardOnTouch(sender: AnyObject) {
        self.webView.goForward()
    }
    
    @IBAction func stopOnTouch(sender: AnyObject) {
        self.webView.stopLoading()
    }
    
    func closeButtonOnTouch() {
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        MBProgressHUD.showHUDAddedTo(self.webView, animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideAllHUDsForView(self.webView, animated: true)
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
