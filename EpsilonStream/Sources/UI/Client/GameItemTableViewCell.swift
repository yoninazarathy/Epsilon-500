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
    
    
    func configureWith(iosAppSearchResult result: IOsAppSearchResultItem){
        //IMAGE
        
        let image = ImageManager.getImage(forKey: result.imageName, withDefault: "Play_icon")
        var img = Toucan(image: image).resize(CGSize(width: 160, height: 160), fitMode: Toucan.Resize.FitMode.crop).image
        img = Toucan(image: img).maskWithRoundedRect(cornerRadius: 30).image
        gameImage.image = img
        
        //TITLE
        gameTitle.text = result.title
        
        //CHANNEL
        gameProducer.text = result.channel
        
        if result.inCollection == false{
            gameProducer.text?.append(" -NIC- ")
        }
    }

    func configureWith(gameWebSearchResult result: GameWebPageSearchResultItem){
        //IMAGE
        
        let image = ImageManager.getImage(forKey: result.imageName, withDefault: "Play_icon")

        var img = Toucan(image: image).resize(CGSize(width: 160, height: 160), fitMode: Toucan.Resize.FitMode.crop).image
        img = Toucan(image: img).maskWithRoundedRect(cornerRadius: 30).image
        gameImage.image = img
        
        //TITLE
        gameTitle.text = result.title
        
        //CHANNEL
        gameProducer.text = result.channel
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
        gameTitle.lineBreakMode = .byWordWrapping
        gameTitle.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
 
}
