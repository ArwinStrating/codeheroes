//
//  ProfileController.swift
//  Gitgame
//
//  Created by Arwin Strating on 01-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var repoLabel: UILabel!
    
    var ref: FIRDatabaseReference!
    
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get user data
        getUser()
        
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.white
        let navBackgroundImage:UIImage! = UIImage(named: "bg")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
        
        // Round picture
        self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2;
        self.avatarImg.layer.borderWidth = 1
        self.avatarImg.layer.borderColor = UIColor.white.cgColor
        self.avatarImg.clipsToBounds = true;
        
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
        
        //dataRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUser() {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["codeName"] as? String ?? ""
            print("username: " + username)
            self.nameLabel!.text = username
            self.myActivityIndicator.stopAnimating()
            //let user = User.init(username: username)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func dataRequest() {
        
        let url = URL(string: "https://api.github.com/users/ArwinStrating")
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "Unknown error")
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    self.setData(data: parsedData!)
                    
                    print(parsedData ?? "No data")
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    func setData(data: NSDictionary)
    {
        DispatchQueue.main.async(execute: {
            self.nameLabel?.text = data["name"] as? String
            self.repoLabel?.text = "Repos: " + String(describing: data["public_repos"] as! Int)
            self.downloadImage(avatarUrl: data["avatar_url"] as! String)
            // Hide loader
            self.myActivityIndicator.stopAnimating()
            return
        })
        
    }
    
    func downloadImage(avatarUrl: String)
    {
        let url = URL(string: avatarUrl)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.avatarImg.image = UIImage(data: data!)
            }
        }
    }
    
}
