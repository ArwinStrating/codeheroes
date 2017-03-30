//
//  UserDetailController.swift
//  Coders
//
//  Created by Arwin Strating on 29-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class UserDetailController: UIViewController {

    var user: User!
    var segmentIndex: Int!
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tint colot for navbar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Round picture
        self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2;
        self.avatarImg.layer.borderWidth = 2
        self.avatarImg.layer.borderColor = UIColor(red: 74/255, green: 168/255, blue: 222/255, alpha: 1).cgColor
        self.avatarImg.clipsToBounds = true;
        
        // Activity Indicator
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        print(segmentIndex)
        
        // Set data for user to labels and imgview
        setUserData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUserData() {
        
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
            let weekOfYear = calendar.component(.weekOfYear, from: Date())
            let year = String(calendar.component(.year, from: Date()))
            date = year + "" + String(weekOfYear)
            formatter.dateFormat = "EEEE"
            let dateType = formatter.string(from: dateObj)
            if(dateType == "Sunday") {
                date = year + "" + String(weekOfYear-1)
            }
        }
        else if(segmentIndex == 2){
            commitsPer = "commits_per_month"
            formatter.dateFormat = "yyyyMM"
            date = formatter.string(from: dateObj)
        }

        nameLabel.text = user.name!
        
        ref = FIRDatabase.database().reference().child("metrics").child("user").child(commitsPer).child(date)
        ref.observe(.value, with: { snapshot in
            let userData = snapshot.childSnapshot(forPath: self.user.name!)
            let avatar = userData.childSnapshot(forPath: "avatar").value
            self.setImage(avatarUrl: avatar! as! String)
        })

        
    }
    
    func setImage(avatarUrl: String) {
        let url = URL(string: avatarUrl)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.avatarImg.image = UIImage(data: data!)
                PKHUD.sharedHUD.hide()
            }
        }
    }
    
}
