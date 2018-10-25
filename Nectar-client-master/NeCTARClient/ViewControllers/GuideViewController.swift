//
//  GuideViewController.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/10/4.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import IBAnimatable

class GuideViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet var start: AnimatableButton!
    @IBOutlet var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    
    let numOfPages = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        super.viewDidLoad()
        
        let frame = self.view.bounds

        scrollView = UIScrollView(frame: frame)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.contentOffset = CGPointZero
        // set the scrollview size to fit the number of pages
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(numOfPages), height: frame.size.height - 20)
        
        
        scrollView.delegate = self
        
        for index  in 0..<numOfPages {
            
            let imageView = UIImageView(image: UIImage(named: "GuideImage\(index + 1)"))
            imageView.frame = CGRect(x: frame.size.width * CGFloat(index), y: 0, width: frame.size.width, height: frame.size.height - 20)
            scrollView.addSubview(imageView)
        }
        
       
        self.view.insertSubview(scrollView, atIndex: 0)
        
        // hide the start button at the beginning
        start.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startOnClick(sender: AnyObject) {
        loginRequired()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // change the pageControl status
        pageControl.currentPage = Int(offset.x / view.bounds.width)
        
        // if sides to the last page, make start button visible
        if pageControl.currentPage == numOfPages - 1 {
            UIView.animateWithDuration(0.5) {
                self.start.alpha = 1.0
            }
        } else {
            UIView.animateWithDuration(0.2) {
                self.start.alpha = 0.0
            }
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
