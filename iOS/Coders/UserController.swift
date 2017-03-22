//
//  UserController.swift
//  Code Heroes
//
//  Created by Arwin Strating on 13-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class User {
    
    var name: String?
    var score: Int?
    
    init(json: NSDictionary) {
        self.name = json["name"] as? String
        self.score = json["score"] as? Int
    }
}

class UserController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var segmentControlIndex: Int = 0
    
    var ref: FIRDatabaseReference!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(UserController.refreshData), for: UIControlEvents.valueChanged)
        
        let githubDark = UIColor(red:36/255.0, green:41/255.0, blue:46/255.0, alpha:1)
        
        self.navigationController?.navigationBar.barTintColor = githubDark
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.white
        let navBackgroundImage:UIImage! = UIImage(named: "bg")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
        
        // Activity Indicator
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        // Back button
        if self.revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
        }
        
        dataRequest(segmentIndex: segmentControlIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataRequest(segmentIndex: Int) {
        
        var date = ""
        var commitsPer = ""
        let dateObj = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if(segmentIndex == 0){
            commitsPer = "commits_per_day"
            formatter.dateFormat = "yyyyMMdd"
            date = formatter.string(from: dateObj)
        }
        else if(segmentIndex == 1){
            commitsPer = "commits_per_week"
            let weekOfYear = String(calendar.component(.weekOfYear, from: Date()))
            let year = String(calendar.component(.year, from: Date()))
            date = year + "" + weekOfYear
        }
        else if(segmentIndex == 2){
            commitsPer = "commits_per_month"
            formatter.dateFormat = "yyyyMM"
            date = formatter.string(from: dateObj)
        }
        
        ref = FIRDatabase.database().reference().child("metrics").child("user").child(commitsPer).child(date)
        ref.observe(.value, with: { snapshot in
            self.users.removeAll()
            for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? [] {
                let key = String(child.key)
                let score = child.childSnapshot(forPath: "score").value!
                let user = [ "name": key!, "score": score] as [String : Any]
                self.users.append(User(json: user as NSDictionary))
                
            }
            if(self.users.count != 0) {
                self.do_table_refresh()
            } else {
                // Hide loader
                PKHUD.sharedHUD.hide()
                self.alert(message: "No scores for today yet")
                self.do_table_refresh()
            }
        })
        
    }
    
    func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    func refreshData()
    {
        DispatchQueue.main.async(execute: {
            self.dataRequest(segmentIndex: self.segmentControlIndex)
            print("data reloaded")
            self.tableView.refreshControl!.endRefreshing()
            return
        })
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Instantiate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UserTableViewCell
        
        cell.userLabel.text = users.sorted(by: { $0.score! > $1.score! })[indexPath.row].name!
        cell.scoreLabel.text = String(users.sorted(by: { $0.score! > $1.score! })[indexPath.row].score!)
    
        // Hide loader
        PKHUD.sharedHUD.hide()
        
        return cell
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            segmentControlIndex = sender.selectedSegmentIndex
            dataRequest(segmentIndex: sender.selectedSegmentIndex)
        }
        else if(sender.selectedSegmentIndex == 1) {
            segmentControlIndex = sender.selectedSegmentIndex
            dataRequest(segmentIndex: sender.selectedSegmentIndex)
        }
        else if(sender.selectedSegmentIndex == 2){
            segmentControlIndex = sender.selectedSegmentIndex
            dataRequest(segmentIndex: sender.selectedSegmentIndex)
        }
    }
    
}

extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


