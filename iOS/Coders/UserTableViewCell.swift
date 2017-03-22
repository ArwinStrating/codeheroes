//
//  UserTableViewCell.swift
//  Code Heroes
//
//  Created by Arwin Strating on 13-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
