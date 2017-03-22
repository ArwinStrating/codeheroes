//
//  ProjectController.swift
//  Code Heroes
//
//  Created by Arwin Strating on 10-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Firebase

class Project {
    
    var name: String?
    var score: Int?
    
    init(json: NSDictionary) {
        self.name = json["name"] as? String
        self.score = json["score"] as? Int
    }
}

class ProjectController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var projects = [Project]()
    
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(RepositoriesController.refreshData), for: UIControlEvents.valueChanged)
        
        let githubDark = UIColor(red:36/255.0, green:41/255.0, blue:46/255.0, alpha:1)
        
        self.navigationController?.navigationBar.barTintColor = githubDark
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.white
        let navBackgroundImage:UIImage! = UIImage(named: "bg")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
        
        // Activity Indicator
        myActivityIndicator.center = CGPoint(x: view.frame.size.width  / 2,
                                             y: view.frame.size.height / 2 - 64);
        
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        dataRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataRequest() {
        
        projects.removeAll()
        
        ref = FIRDatabase.database().reference().child("metrics").child("project").child("commits_today")
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? [] {
                //print(child.childSnapshot(forPath: "score").value!)
                
                let key = child.key
                let score = child.childSnapshot(forPath: "score").value!
                let project = [ "name": key, "score": score ]
                self.projects.append(Project(json: project as NSDictionary))
            }
            self.do_table_refresh()
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
            self.dataRequest()
            print("data reloaded")
            self.refreshControl!.endRefreshing()
            return
        })
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Instantiate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ProjectTableViewCell
        
        // Set values to labels
        cell.projectLabel.text = projects[indexPath.row].name!
        cell.scoreLabel.text = String(projects[indexPath.row].score!)
        
        // Hide loader
        myActivityIndicator.stopAnimating()
        
        return cell
    }
    
}

