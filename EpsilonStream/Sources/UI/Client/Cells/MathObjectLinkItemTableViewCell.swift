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
    
    static var styles: [String: (backgroundColor: UIColor, backgroundAlpha: CGFloat, backgroundImageName: String?, imageName: String?)] =
        [ "default"               : (.white,                    1,      nil,                                nil),
          "GMP-Style"             : (.white,                    1,      "CellGMPBackground",                "CellGMPImage"),
          "OneOnEpsilon-Style"    : (.white,                    1,      "CellWhiteWithShadowBackground",    "CellOneOnEpsilonImage"),
          "Youtube-Style"         : (.white,                    1,      "CellWhiteWithShadowBackground",    "CellYoutubeImage"),
          "play-image"            : (UIColor(rgb: ES_play1),    0.4,    "CellWhiteWithShadowBackground",    "Play_icon"),
          "explore-image"         : (UIColor(rgb: ES_explore1), 0.4,    "CellWhiteWithShadowBackground",    "Explore_icon"),
          "watch-image"           : (UIColor(rgb: ES_watch1),   0.4,    "CellWhiteWithShadowBackground",    "Watch_icon") ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWith(mathObjectLinkSearchResult searchResult: MathObjectLinkSearchResultItem){
        //
        titleLabel.text = searchResult.title
        detailLabel.text = searchResult.titleDetail
        //
        //
        var style = MathObjectLinkItemTableViewCell.styles[searchResult.imageKey]
        if style == nil {
            style = MathObjectLinkItemTableViewCell.styles["default"]
        }
        
        if style?.backgroundImageName != nil && style?.backgroundImageName?.isEmpty == false {
            backgroundView = UIImageView(image: UIImage(named: style!.backgroundImageName!) )
        }
        if style?.imageName != nil && style?.imageName?.isEmpty == false {
            leftUIImage.image = UIImage(named: style!.imageName!)
        }
        backgroundColor = style!.backgroundColor
        backgroundView?.alpha = style!.backgroundAlpha
        //
    }
}
