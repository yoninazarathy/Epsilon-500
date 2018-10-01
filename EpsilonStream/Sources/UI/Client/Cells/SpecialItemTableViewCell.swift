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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func suggestAction(_ sender: UIButton) {
        if let vc = clientSearchViewController{
            //QQQQ configure with user suggestion
            vc.jumpToWebPage(withURLstring: "https://oneonepsilon.com/contact", withSplashKey: "OoE-splash")
        }
    }
    
    func configureWith(specialSearchResultItem result: SpecialSearchResultItem){
        mainLabel.text = result.title
    }
}
