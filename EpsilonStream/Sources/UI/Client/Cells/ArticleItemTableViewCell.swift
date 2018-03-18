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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView = UIImageView(image: UIImage(named: "tableCell1"))
        articleTitle.lineBreakMode = .byWordWrapping
        articleTitle.numberOfLines = 0
    }
    
    func configureWith(articleSearchResult searchResult: BlogWebPageSearchResultItem){
        //IMAGE
        let image = ImageManager.image(at: searchResult.imageURL, forKey: searchResult.imageName, withDefaultName: "Explore_icon")
        
        //QQQQ too small
        let img = Toucan(image: image).resize(CGSize(width: 150, height: 150), fitMode: Toucan.Resize.FitMode.crop).image
        articleImage.image = Toucan(image: img).maskWithEllipse().image
        
        //TITLE
        articleTitle.text = searchResult.title
        
        //CHANNEL
        articleProducer.text = searchResult.channel
        
        if searchResult.inCollection == false {
            articleProducer.text?.append(" -NIC- ")
        }
    }
}
