//
//  TemplateVersionDetailCell.swift
//  NeCTARClient
//
//  Created by Qi Qi on 2/10/18.
//  Copyright © 2018 Xinrui Xu. All rights reserved.
//

import UIKit

class TemplateVersionDetailCell: UITableViewCell {
    
    @IBOutlet var function: UILabel!
    @IBOutlet var descrip: UILabel!
    
    // Set the detail of a cell according to the associated template version's index
    func setContent(templateIndex: Int, functionIndex: Int) {
        let template = TemplateVersionService.sharedService.templateDetails[templateIndex][functionIndex]
        function.text = template.function
        descrip.text = template.descrip
        
    }
}
