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
    
    
    func configureWith(userMessageResultItem result: UserMessageResultItem){
        mainLabel.text = result.title
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //backgroundView = UIImageView(image: UIImage(named:"standardBack"))
        //QQQQ articleTitle.lineBreakMode = .byWordWrapping
        //QQQQ articleTitle.numberOfLines = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

