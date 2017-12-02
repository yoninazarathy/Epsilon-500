import UIKit

extension UIView {    
    func addRoundedCorners(corners: UIRectCorner, radii: CGSize) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        
        let path = UIBezierPath(roundedRect: maskLayer.bounds, byRoundingCorners: corners, cornerRadii: radii)
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    func addRoundedCorners(corners: UIRectCorner, radius: CGFloat) {
        addRoundedCorners(corners: corners, radii: CGSize(width: radius, height: radius) )
    }
    
    func removeRoundedCorners() {
        layer.mask = nil
    }
}
