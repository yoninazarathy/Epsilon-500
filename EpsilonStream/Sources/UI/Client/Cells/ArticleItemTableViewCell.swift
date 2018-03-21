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
        
        backgroundView = UIImageView(image: UIImage(named: "CellWhiteWithShadowBackground"))
        articleTitle.lineBreakMode = .byWordWrapping
        articleTitle.numberOfLines = 0
    }
    
    func configureWith(articleSearchResult searchResult: BlogWebPageSearchResultItem){
        // IMAGE
        let width = UIScreen.main.scale * 100
        var image = ImageManager.image(at: searchResult.imageURL, forKey: searchResult.imageName, withDefaultName: "Explore_icon")
        image = Toucan(image: image).resize(CGSize(width: width), fitMode: Toucan.Resize.FitMode.crop).image
        articleImage.image = Toucan(image: image).maskWithEllipse().image
        
        // TITLE
        articleTitle.text = searchResult.title
        
        // CHANNEL
        articleProducer.text = searchResult.channel
        
        if searchResult.inCollection == false {
            articleProducer.text?.append(" -NIC- ")
        }
    }
}
