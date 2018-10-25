//
//  SelfDefineButton.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/9/24.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit

class SelfDefineButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // redesign the layout of the button, make title below image
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageX: CGFloat = 0;
        let imageY: CGFloat = 0;
        let imageW = self.bounds.size.width;
        let imageH = self.bounds.size.height * 0.8;
        self.imageView?.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        
        // UILabel
        let labelY: CGFloat = imageH;
        let labelH = self.bounds.size.height - labelY;
        self.titleLabel?.frame = CGRectMake(imageX, labelY, imageW, labelH);
    }
    
}
