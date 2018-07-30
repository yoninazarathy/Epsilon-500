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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isTop { //QQQQ handle this - and move elsewhere
            backgroundView = nil
        } else {
            backgroundView = UIImageView(image: UIImage(named:"CellWhiteWithShadowBackground"))
        }
        
        videoTitle.lineBreakMode = .byWordWrapping
        videoTitle.numberOfLines = 0
    }
    
    func configureWith(videoSearchResult searchResult: VideoSearchResultItem){
        // IMAGE
        let imageCompletion: (UIImage?)->() = { (image) in
            if let image = image {
                //QQQQ perfromance: move this resizing offline?
                let height = image.size.height
                let width = image.size.width
                
                let newHeight = height*0.75 //has to do with black lines on youtube videos QQQQ configure
                let newWidth = width
                
                let img = Toucan(image: image).resize(CGSize(width: newWidth, height: newHeight), fitMode: Toucan.Resize.FitMode.crop).image
                
                self.videoImage.image = img
            }
        }
        let image = ImageManager.image(at: searchResult.imageURL, forKey: searchResult.imageName, withDefaultName: "Explore_icon", completion: imageCompletion)
        imageCompletion(image)
        //
        
        
        
        //TITLE
        videoTitle.text = searchResult.title
        
        // IK: Why??? UILabel can cut text automatically
        if let len = videoTitle.text?.count {
            if len > 45 { //QQQQ lazy let?
                videoTitle.text = videoTitle.text?.substring(to: 45).appending(" ...")
            }
        }
        //
        
        //CHANNEL
        videoChannel.text = searchResult.channel

        //DURATION
        if let dur = searchResult.durationString {
            //duration.text = ""//dur
            videoChannel.text?.append(", \(dur) min")
        } else {
            DLog("ERROR - missing duration \(searchResult.youtubeId)")
        }
        
        //PROGRESS
        let dataPercent = searchResult.percentWatched
        if dataPercent <= 3 {
            videoProgress.progress = 0.0
        }else if dataPercent >= 98 {
            videoProgress.progress = 1.0
        } else {
         videoProgress.progress = dataPercent / 100
        }
        
        if searchResult.inCollection == false{
            videoChannel.text?.append(" -NIC- ") //QQQQ do this for games and articls too.
        }
    }
}
