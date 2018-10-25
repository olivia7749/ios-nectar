//
//  TemplateVersionCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class TemplateVersionCell: UITableViewCell {
    
    @IBOutlet var version: UILabel!
    @IBOutlet var type: UILabel!
    
    // Set the content of a cell according to the associated template version's index
    func setContent(index: Int) {
        let template = TemplateVersionService.sharedService.templateVersions[index]
        version.text = template.version
        type.text = template.type
        
    }
}