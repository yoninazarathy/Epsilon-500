import UIKit

extension String {
    public func size(withConstrainedWidth width: CGFloat = .greatestFiniteMagnitude, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingRect = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingRect.size
    }
}
