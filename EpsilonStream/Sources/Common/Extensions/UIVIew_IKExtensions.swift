import UIKit

extension UIView {    
    public func addRoundedCorners(corners: UIRectCorner, radii: CGSize) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        
        let path = UIBezierPath(roundedRect: maskLayer.bounds, byRoundingCorners: corners, cornerRadii: radii)
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    public func addRoundedCorners(corners: UIRectCorner, radius: CGFloat) {
        addRoundedCorners(corners: corners, radii: CGSize(width: radius, height: radius) )
    }
    
    public func removeRoundedCorners() {
        layer.mask = nil
    }
    
    public static func topOrigin(forView view: UIView, withSize size: CGSize, originX: CGFloat) -> CGPoint {
        var origin = CGPoint(x: originX, y: 0)
        if view.superview != nil {
            if #available(iOS 11, tvOS 11, *) {
                origin.y = view.superview!.safeAreaInsets.top
            }
        }
        return origin
    }
    
    public static func bottomOrigin(forView view: UIView, withSize size: CGSize, originX: CGFloat) -> CGPoint {
        var origin = CGPoint(x: originX, y: 0)
        if view.superview != nil {
            origin.y = view.superview!.bounds.height - size.height
            if #available(iOS 11, tvOS 11, *) {
                origin.y -= view.superview!.safeAreaInsets.bottom
            }
        }
        return origin
    }
}
