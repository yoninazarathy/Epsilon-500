import UIKit
import Toucan

class SearchResultCell: BaseCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var defaultImageName: String {
        return ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView = UIImageView(image: UIImage(named: "CellWhiteWithShadowBackground"))
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
    }
    
    func configureWith(searchResult: SearchResultItem) {
        //
        if searchResult.imageName.isEmpty == false {
            let width = UIScreen.main.scale * 100
            let imageCompletion: (UIImage?)->() = { (image) in
                if let image = image {
                    let procecedImage = Toucan(image: image).resize(CGSize(width: width), fitMode: Toucan.Resize.FitMode.crop).image
                    self.mainImageView.image = Toucan(image: procecedImage).maskWithEllipse().image
                }
            }
            let image = ImageManager.image(at: searchResult.imageURL, forKey: searchResult.imageName,
                                           withDefaultName: defaultImageName, completion: imageCompletion)
            imageCompletion(image)
            
        } else {
            if defaultImageName.isEmpty {
                mainImageView.image = nil
            } else {
                mainImageView.image = UIImage(named: defaultImageName)
            }
        }
        //
        //
        titleLabel.text = searchResult.title
        //
        //
        subtitleLabel.text = searchResult.channel
        
        if searchResult.inCollection == false {
            subtitleLabel.text?.append(" -NIC- ")
        }
        //
    }

}
