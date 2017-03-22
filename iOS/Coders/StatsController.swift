//
//  StatsController.swift
//  Code Heroes
//
//  Created by Arwin Strating on 14-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Firebase
import PKHUD
import Charts

class StatsController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var commitsLabel: UILabel!
    
    var ref: FIRDatabaseReference!
    var months: [String]!
    var unitsSold: [Int]!
    var commits: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        getStats()
        
        // Menu button
        if self.revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setChart(dataPoints: [String], values: [Int]) {
        barChartView?.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Commits")
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        barChartView.data = chartData
        
        chartDataSet.colors = [UIColor(red: 63/255, green: 64/255, blue: 51/255, alpha: 1)]
        chartData.setValueTextColor(UIColor.white)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // Disable zoom
        barChartView.doubleTapToZoomEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        // Hide legend
        barChartView.legend.enabled = false
        // Hide grid
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false
        // Hide description
        barChartView.chartDescription?.text = ""
        // Set xAxis labels and hide left and right axis labels, show labels in bar
        barChartView.xAxis.drawLabelsEnabled = true
        barChartView.xAxis.labelPosition = .bottom
        barChartView.leftAxis.drawLabelsEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        // Set xAxis text to months
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        barChartView.xAxis.granularity = 1
    }
    
    func getStats() {
        var commits = [Int]()
        
        var lastYearCount = 0
        var novCountLastYear = 0
        var thisYearCount = 0
        var janCountThisYear = 0
        var febCountThisYear = 0
        var marCountThisYear = 0
        var aprCountThisYear = 0
        var mayCountThisYear = 0
        var junCountThisYear = 0
        var julCountThisYear = 0
        var augCountThisYear = 0
        var sepCountThisYear = 0
        var octCountThisYear = 0
        var novCountThisYear = 0
        var decCountThisYear = 0
        
        ref = FIRDatabase.database().reference().child("on").child("commit")
        ref.observe(.value, with: { snapshot in
            print(snapshot.childrenCount)
            self.commitsLabel.text = String(snapshot.childrenCount) + " commits"
            for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? [] {
                let timestamp = child.childSnapshot(forPath: "timestamp").value! as! String
                let index = timestamp.index(timestamp.startIndex, offsetBy: 4)
                let monthIndexStart = timestamp.index(timestamp.startIndex, offsetBy: 5)
                let monthIndexEnd = timestamp.index(timestamp.startIndex, offsetBy: 7)
                let monthRange = monthIndexStart..<monthIndexEnd
                let year = timestamp.substring(to: index)
                let month = timestamp.substring(with: monthRange)
                if(year == "2016") {
                    lastYearCount += 1
                    if(month == "11") {
                        novCountLastYear += 1
                    }
                }
                if(year == "2017") {
                    thisYearCount += 1
                    if(month == "01") {
                        janCountThisYear += 1
                    }
                    if(month == "02") {
                        febCountThisYear += 1
                    }
                    if(month == "03") {
                        marCountThisYear += 1
                    }
                    if(month == "04") {
                        aprCountThisYear += 1
                    }
                    if(month == "05") {
                        mayCountThisYear += 1
                    }
                    if(month == "06") {
                        junCountThisYear += 1
                    }
                    if(month == "07") {
                        julCountThisYear += 1
                    }
                    if(month == "08") {
                        augCountThisYear += 1
                    }
                    if(month == "09") {
                        sepCountThisYear += 1
                    }
                    if(month == "10") {
                        octCountThisYear += 1
                    }
                    if(month == "11") {
                        novCountThisYear += 1
                    }
                    if(month == "12") {
                        decCountThisYear += 1
                    }
                }
            }
            commits.append(janCountThisYear)
            commits.append(febCountThisYear)
            commits.append(marCountThisYear)
            commits.append(aprCountThisYear)
            commits.append(mayCountThisYear)
            commits.append(junCountThisYear)
            commits.append(julCountThisYear)
            commits.append(augCountThisYear)
            commits.append(sepCountThisYear)
            commits.append(octCountThisYear)
            commits.append(novCountThisYear)
            commits.append(decCountThisYear)

            print(commits)
            
            print("2016: " + String(lastYearCount))
            print("2016 nov: " + String(novCountLastYear))
            print("2017: " + String(thisYearCount))
            print("2017 jan: " + String(janCountThisYear))
            print("2017 feb: " + String(febCountThisYear))
            print("2017 mar: " + String(marCountThisYear))
            print("2017 apr: " + String(aprCountThisYear))
            print("2017 may: " + String(mayCountThisYear))
            print("2017 jun: " + String(junCountThisYear))
            print("2017 jul: " + String(julCountThisYear))
            print("2017 aug: " + String(augCountThisYear))
            print("2017 sep: " + String(sepCountThisYear))
            print("2017 oct: " + String(octCountThisYear))
            print("2017 nov: " + String(novCountThisYear))
            print("2017 dec: " + String(decCountThisYear))
            PKHUD.sharedHUD.hide()
            self.setChart(dataPoints: self.months, values: commits)
        })
        
    }
}
