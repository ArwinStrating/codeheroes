//
//  ViewController.swift
//  Gitgame
//
//  Created by Arwin Strating on 23-02-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import PKHUD

class Repository {
    
    var name: String?
    var full_name: String?
    
    init(json: NSDictionary) {
        self.name = json["name"] as? String
        self.full_name = json["full_name"] as? String
    }
}

var ref: FIRDatabaseReference!

class RepositoriesController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var repositories = [Repository]()
    
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(RepositoriesController.refreshData), for: UIControlEvents.valueChanged)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "ProductSans-Regular", size: 17.0)!, NSForegroundColorAttributeName: UIColor.white]
        
        // Activity Indicator
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        if self.revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
        }
        
        getRepos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRepos() {
        var githubName = ""
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            githubName = value?["github_username"] as? String ?? ""
            self.dataRequest(githubName: githubName)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func dataRequest(githubName: String) {
        let url = URL(string: "https://api.github.com/users/" + githubName + "/subscriptions")
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
        if error != nil {
            print(error ?? "Unknown error")
        } else {
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray
                self.repositories.removeAll()
                
                var max = 20
                if (parsedData?.count)! < 20
                {
                    max = (parsedData?.count)!
                }
                    
                for i in 0..<max //list.count
                {
                    if let data_block = parsedData?[i] as? NSDictionary
                    {
                        self.repositories.append(Repository(json: data_block))
                    }
                }
                
                self.do_table_refresh()
                    
            } catch let error as NSError {
                    print(error)
            }
        }
            
        }.resume()
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
            self.getRepos()
            print("data reloaded")
            self.refreshControl!.endRefreshing()
            return
        })
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return repositories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Instantiate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RepoTableViewCell
        
        // Set values to labels
        cell.nameLabel.text = repositories[indexPath.row].name!
        cell.fullNameLabel.text = repositories[indexPath.row].full_name!
        
        // Hide loader
        PKHUD.sharedHUD.hide()
        
        return cell
    }

}

