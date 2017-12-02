import UIKit

extension UILabel {
    public func sizeWithConstrainedSize(_ size: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                height: CGFloat.greatestFiniteMagnitude)) -> CGSize {
        return self.textRect(forBounds: CGRect(origin: CGPoint.zero, size: size), limitedToNumberOfLines: numberOfLines).size
    }
}
