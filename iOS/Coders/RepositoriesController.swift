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

class Repository {
    
    var name: String?
    var full_name: String?
    
    init(json: NSDictionary) {
        self.name = json["name"] as? String
        self.full_name = json["full_name"] as? String
    }
}

class RepositoriesController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var repositories = [Repository]()
    
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
        
        if self.revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
        }
        
        dataRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataRequest() {
        
        let url = URL(string: "https://api.github.com/users/ArwinStrating/subscriptions")
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
            self.dataRequest()
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
        myActivityIndicator.stopAnimating()
        
        return cell
    }

}

