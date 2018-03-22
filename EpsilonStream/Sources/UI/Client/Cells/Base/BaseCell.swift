import UIKit

class BaseCell: UITableViewCell, ViewRefreshProtocol {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    func initialize() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        refresh()
    }
    
    func refresh() {
        
    }
}
