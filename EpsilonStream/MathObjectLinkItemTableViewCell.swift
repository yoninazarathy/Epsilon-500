//
//  MathObjectLinkItemTableViewCell.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 21/7/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class MathObjectLinkItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftUIImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    //@IBOutlet weak var mainImageView: UIImageView!
    
    //@IBOutlet weak var titleLabel: UILabel!
    
    func configureWith(mathObjectLinkSearchResult result: MathObjectLinkSearchResultItem){
        
        titleLabel.text = result.title
        detailLabel.text = result.titleDetail
        
        
        //QQQQ horrible code 
        if result.imageKey == "GMP-Style"{
            backgroundView = UIImageView(image: UIImage(named:"desktop_landscape_backgroundLight"))
            leftUIImage.image = UIImage(named:"gmp_balloon_gray")
        }else if result.imageKey == "OneOnEpsilon-Style"{
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
            leftUIImage.image = UIImage(named:"OneOnEpsilonLogo3")
        } else if result.imageKey == "Youtube-Style"{
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
            leftUIImage.image = UIImage(named:"youtubeRound")
        }else if result.imageKey == "play-image"{
            backgroundColor = UIColor(rgb: ES_play1)
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
            backgroundView?.alpha = 0.4
            leftUIImage.image = UIImage(named:"Play_icon")
        }else if result.imageKey == "explore-image"{
            backgroundColor = UIColor(rgb: ES_explore1)
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
            backgroundView?.alpha = 0.4
            leftUIImage.image = UIImage(named:"Explore_icon")
        }else if result.imageKey == "watch-image"{
            backgroundColor = UIColor(rgb: ES_watch1)
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
            backgroundView?.alpha = 0.4
            leftUIImage.image = UIImage(named:"Watch_icon")
        }else{
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
            leftUIImage.image = UIImage(named:"eStreamIcon")
        }

        
        //IMAGE
        if let image = result.image{
            //QQQQ too small
            // QQQQ do it
      //      let img = Toucan(image: image).resize(CGSize(width: 50, height: 50), fitMode: Toucan.Resize.FitMode.crop).image
        //    articleImage.image = Toucan(image: img).maskWithEllipse().image
        }else{
            print("error - using default image")
            //articleImage.image = UIImage(named: "OneOnEpsilonLogo3")
        }
        
        //TITLE
       // articleTitle.text = result.title
        
        //CHANNEL
      //  articleProducer.text = result.channel
      
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //QQQQ articleTitle.lineBreakMode = .byWordWrapping
        //QQQQ articleTitle.numberOfLines = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
