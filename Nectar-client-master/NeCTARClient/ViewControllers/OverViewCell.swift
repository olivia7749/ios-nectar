//
//  OverViewCell.swift
//  NeCTARClient
//
//  Created by Ding Wang on 16/8/18.
//  Copyright © 2016年 Ding Wang. All rights reserved.
//

import UIKit
import Charts

class OverViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var usagelabel: UILabel!
    @IBOutlet var piechart: PieChartView!

    
    func setChart (dataPoints: [String], values: [Double]){
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        let total = values[0] + values[1]
        if total == -1 {
            let vtotal = "No Limit"
            usagelabel.text = "Used \(values[0]) of \(vtotal)"
            
        } else {
            usagelabel.text = "Used \(values[0]) of \(total)"
        }
        
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: nil)
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        
        
        piechart.data = pieChartData
        pieChartDataSet.colors = [UIColor.redColor(), UIColor.lightGrayColor()]
        piechart.legend.enabled = false
        piechart.descriptionText = ""
        piechart.animate(yAxisDuration: 1)
    }

}
