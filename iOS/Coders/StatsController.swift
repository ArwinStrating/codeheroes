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
    var totalScore: Int = 0
    
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
        
        chartDataSet.colors = [UIColor(red: 74/255, green: 168/255, blue: 222/255, alpha: 1)]
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
        barChartView.xAxis.yOffset = -15
        // Set xAxis text to months
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.setLabelCount(24, force: true)
    }
    
    func getStats() {
        var commits = [Int]()
        
        ref = FIRDatabase.database().reference().child("metrics").child("user").child("commits_per_month")
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? [] {
                let key = child.key
                let index = key.index(key.startIndex, offsetBy: 4)
                let monthIndexStart = key.index(key.startIndex, offsetBy: 4)
                let monthIndexEnd = key.index(key.startIndex, offsetBy: 6)
                let monthRange = monthIndexStart..<monthIndexEnd
                let year = key.substring(to: index)
                let month = key.substring(with: monthRange)
                print(year, month)
                if(year == "2016") {
                    if(month == "11") {
                        for childTwo in child.children.allObjects as? [FIRDataSnapshot] ?? [] {
                            print(childTwo.childSnapshot(forPath: "score").value!)
                        }
                    }
                }
                if(year == "2017") {
                    var totalScore: Int = 0
                    for childTwo in child.children.allObjects as? [FIRDataSnapshot] ?? [] {
                        totalScore += childTwo.childSnapshot(forPath: "score").value! as! Int
                    }
                    print("Commits ", month, ": " ,totalScore)
                    commits.append(totalScore)
                }
            }
            var i = 1
            while i <= 12 {
                if(commits.count < 12) {
                    commits.append(0)
                }
                i = i + 1
            }
            
            PKHUD.sharedHUD.hide()
            self.setChart(dataPoints: self.months, values: commits)
        })
        
    }
}
