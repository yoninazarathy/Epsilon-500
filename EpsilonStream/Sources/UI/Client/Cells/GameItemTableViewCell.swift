//
//  GameItemTableViewCell.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 25/6/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Toucan

class GameItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameProducer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView = UIImageView(image: UIImage(named: "CellWhiteWithShadowBackground"))
        gameTitle.lineBreakMode = .byWordWrapping
        gameTitle.numberOfLines = 0
    }

    
    func configureWith(searchResult: SearchResultItem){
        //IMAGE
        let image = ImageManager.image(at: searchResult.imageURL, forKey: searchResult.imageName, withDefaultName: "Play_icon")
        var img = Toucan(image: image).resize(CGSize(width: 160, height: 160), fitMode: Toucan.Resize.FitMode.crop).image
        img = Toucan(image: img).maskWithRoundedRect(cornerRadius: 30).image
        gameImage.image = img
        
        //TITLE
        gameTitle.text = searchResult.title
        
        //CHANNEL
        gameProducer.text = searchResult.channel
        
        if searchResult.inCollection == false {
            gameProducer.text?.append(" -NIC- ")
        }
    }

}
