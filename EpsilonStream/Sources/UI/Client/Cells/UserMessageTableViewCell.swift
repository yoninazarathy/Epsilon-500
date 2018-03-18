//
//  UserMessageTableViewCell.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 4/11/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class UserMessageTableViewCell: UITableViewCell {

    var clientSearchViewController: ClientSearchViewController? = nil
        
    @IBOutlet weak var mainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWith(userMessageResultItem result: UserMessageResultItem){
        mainLabel.text = result.title
    }
}

