//
//  VideoItemTableViewCell.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 25/6/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Toucan

class VideoItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoProgress: UIProgressView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoChannel: UILabel!
    
    var isTop = false
    
    func configureWith(videoSearchResult result: VideoSearchResultItem){
        //IMAGE
        
        let image = ImageManager.getImage(forKey: result.imageName, withDefault: "Watch_icon")
        
        //QQQQ perfromance: move this resizing offline?
        let height = image.size.height
        let width = image.size.width
        
        let newHeight = height*0.75 //has to do with black lines on youtube videos QQQQ configure
        let newWidth = width
            
        let img = Toucan(image: image).resize(CGSize(width: newWidth, height: newHeight), fitMode: Toucan.Resize.FitMode.crop).image
            
        videoImage.image = img
        
        //TITLE
        videoTitle.text = result.title
        
        if let len = videoTitle.text?.characters.count{
            if len > 45{ //QQQQ lazy let?
                videoTitle.text = videoTitle.text?.chopSuffix(len-45).appending(" ...")
            }
        }
        
        //CHANNEL
        videoChannel.text = result.channel

        //DURATION
        if let dur = result.durationString{
            //duration.text = ""//dur
            videoChannel.text?.append(", \(dur) min")
        }else{
            print("ERROR - missing duration \(result.youtubeId)")
        }
        
        //PROGRESS
        let dataPercent = result.percentWatched
        if dataPercent <= 3{
            videoProgress.progress = 0.0
        }else if dataPercent >= 98{
            videoProgress.progress = 1.0
        }else{
         videoProgress.progress =  dataPercent/100
        }
        
        if result.inCollection == false{
            videoChannel.text?.append(" -NIC- ") //QQQQ do this for games and articls too.
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isTop{//QQQQ handle this - and move elsewhere
            backgroundView = nil
        }else{
            backgroundView = UIImageView(image: UIImage(named:"tableCell1"))
        }

        videoTitle.lineBreakMode = .byWordWrapping
        videoTitle.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
