import UIKit


extension UIImage {
    
    // MARK: Misc
    
    private func transformContext(context: CGContext) {
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        context.translateBy(x: 0, y: CGFloat(context.height))
        // Now, draw the rotated/scaled image into the context
        context.scaleBy(x: 1, y: -1)
    }
    
    // MARK: Colors
    
    public static func image(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
    
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
    
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return image
    }
    
    public func maskedImage(color: UIColor) -> UIImage? {
        let rect = CGRect(origin: CGPoint.zero, size: self.size)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.draw(in: rect)
        context?.setFillColor(color.cgColor)
        context?.setBlendMode(.sourceAtop)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public static func maskedImage(named name: String, color: UIColor) -> UIImage? {
        return UIImage(named: name)?.maskedImage(color: color)
    }
    
    // MARK: Crop/Resize
    
    public func cropping(to rect: CGRect) -> UIImage? {
        let scale = self.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale,
                                width: rect.size.width * scale, height: rect.size.height * scale)
        let cgImage = self.cgImage?.cropping(to: scaledRect)
        guard cgImage != nil else {
            return nil
        }
        
        return UIImage(cgImage: cgImage!, scale: scale, orientation: self.imageOrientation)
    }
    
    public func rotating(by angle: CGFloat) -> UIImage? {
        // Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: self.size))
        let transform = CGAffineTransform(rotationAngle: angle)
        rotatedViewBox.transform = transform;
        let rotatedSize = rotatedViewBox.frame.size
    
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let context = UIGraphicsGetCurrentContext();
    
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        context?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    
        // Rotate the image context
        context?.rotate(by: angle)
    
        // Now, draw the rotated/scaled image into the context
        context?.scaleBy(x: 1, y: -1)
        context?.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
    
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    
        return image
    }
    
    public func resizing(to size: CGSize) -> UIImage? {
        // Create a bitmap graphics context
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale);
    
        // Draw the scaled image in the current context
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
    
        // Create a new image from current context
        let image = UIGraphicsGetImageFromCurrentImageContext()
    
        // Pop the current context from the stack
        UIGraphicsEndImageContext();
    
        // Return our new scaled image
        return image
    }
    
    // MARK: UIImage from UIView and etc.
    
    public static func image(fromLayer layer: CALayer, ignoreScreenScale: Bool = false) -> UIImage? {
        let scale = UIScreen.main.scale
    
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, true, (ignoreScreenScale == true) ? 1 : scale);
    
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
    
        layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    
        return image
    }
    
    public static func image(fromView view: UIView, ignoreScreenScale: Bool = false) -> UIImage? {
        return image(fromLayer: view.layer, ignoreScreenScale: ignoreScreenScale)
    }
    
    // MARK: Misc
    
    public var hasAlpha: Bool {
        let alpha = self.cgImage?.alphaInfo
        return alpha == CGImageAlphaInfo.first || alpha == CGImageAlphaInfo.last ||
            alpha == CGImageAlphaInfo.premultipliedFirst || alpha == CGImageAlphaInfo.premultipliedLast
    }
    
    public func saveToPhotosAlbum(target: Any?, selector: Selector?, contextInfo: UnsafeMutableRawPointer? = nil) {
        UIImageWriteToSavedPhotosAlbum(self, target, selector, contextInfo);
    }
    
    public func normalizedImage() -> UIImage? {
        // http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
        // Warning! This method is slow and consumes a lot of memory on large images.
    
        if (self.imageOrientation == .up) {
            return self
        }
    
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return image
    }
    
    func addingShadow(color: UIColor = UIColor(white: 0, alpha: 1), offset: CGSize = CGSize(width: 1, height: 1), blur: CGFloat = 1) -> UIImage {
    
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width + 2 * blur, height: size.height + 2 * blur), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setShadow(offset: offset, blur: blur, color: color.cgColor)
        draw(in: CGRect(x: blur - offset.width / 2, y: blur - offset.height / 2, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }

}
