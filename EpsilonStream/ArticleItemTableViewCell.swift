//
//  ArticleItemTableViewCell.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 25/6/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Toucan

class ArticleItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleProducer: UILabel!
    
    func configureWith(articleSearchResult result: BlogWebPageSearchResultItem){
        //IMAGE
        let image = ImageManager.getImage(forKey: result.imageName, withDefault: "Explore_icon")

        //QQQQ too small
        let img = Toucan(image: image).resize(CGSize(width: 50, height: 50), fitMode: Toucan.Resize.FitMode.crop).image
        articleImage.image = Toucan(image: img).maskWithEllipse().image
        
        //TITLE
        articleTitle.text = result.title
        
        //CHANNEL
        articleProducer.text = result.channel
        
        if result.inCollection == false{
            articleProducer.text?.append(" -NIC- ")
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
        articleTitle.lineBreakMode = .byWordWrapping
        articleTitle.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
