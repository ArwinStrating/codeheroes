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
import PKHUD

class ProfileController: UIViewController{
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get user data
        getUser()
        getScores()
        
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.white
        let navBackgroundImage:UIImage! = UIImage(named: "bg")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
        
        // Round picture
        self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2;
        self.avatarImg.layer.borderWidth = 1
        self.avatarImg.layer.borderColor = UIColor.white.cgColor
        self.avatarImg.clipsToBounds = true;
        
        // Activity Indicator
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
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
        var githubName = ""
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["codeName"] as? String ?? ""
            githubName = value?["github_username"] as? String ?? ""
            print("username: " + username)
            self.nameLabel!.text = username
            self.dataRequest(githubName: githubName)
            //let user = User.init(username: username)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getScores() {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("scores").child("user_scores").child(userID!).child("commits_per_day").child("20170308").observeSingleEvent(of: .value, with: { (snapshot) in
            let level = String(describing: snapshot.childSnapshot(forPath: "level").value!)
            let quote = String(describing: snapshot.childSnapshot(forPath: "quote").value!)
            self.levelLabel.text = "Level: " + level
            self.quoteLabel.text = quote
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func dataRequest(githubName: String) {
        
        let url = URL(string: "https://api.github.com/users/" + githubName)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "Unknown error")
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    self.setData(data: parsedData!)
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    func setData(data: NSDictionary)
    {
        DispatchQueue.main.async(execute: {
            self.downloadImage(avatarUrl: data["avatar_url"] as! String)
            // Hide loader
            PKHUD.sharedHUD.hide()
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
