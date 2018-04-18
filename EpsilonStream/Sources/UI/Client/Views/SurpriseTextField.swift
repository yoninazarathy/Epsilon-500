import UIKit

class SurpriseTextField: UITextField {
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let gap = CGFloat(3)
        let size = CGSize(width: bounds.height - 2 * gap)
        let origin = CGPoint(x: bounds.width - size.width - gap, y: gap)
        return CGRect(origin: origin, size: size)
    }
}
