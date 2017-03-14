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

class StatsController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStats()
        
        // Menu button
        if self.revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getStats() {
        ref = FIRDatabase.database().reference().child("on").child("commit")
        ref.observe(.value, with: { snapshot in
            print(snapshot.childrenCount)
            for child in snapshot.children.allObjects as? [FIRDataSnapshot] ?? [] {
                let key = String(child.key)
                let score = child.childSnapshot(forPath: "score").value!
                
            }
        })

    }
}
