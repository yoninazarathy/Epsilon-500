//
//  SpecialItemTableViewCell.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 21/7/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class SpecialItemTableViewCell: UITableViewCell {
    
    var clientSearchViewController: ClientSearchViewController? = nil
    
    @IBOutlet weak var mainLabel: UILabel!
        
    @IBAction func suggestAction(_ sender: UIButton) {
        if let vc = clientSearchViewController{
            //QQQQ configure with user suggestion
            vc.jumpToWebPage(withURLstring: "https://www.oneonepsilon.com/contact",withSplashKey: "OoE-splash")
        }
    }
    //@IBOutlet weak var mainImageView: UIImageView!
    
    //@IBOutlet weak var titleLabel: UILabel!
    
    func configureWith(specialSearchResultItem result: SpecialSearchResultItem){
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
