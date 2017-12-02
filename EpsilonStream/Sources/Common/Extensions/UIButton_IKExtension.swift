import UIKit


extension UIButton {
    
    public convenience init(frame: CGRect, normaImage: UIImage?, pressedImage: UIImage? = nil,
                            normalTitle: String? = nil, pressedTitle: String? = nil) {
        
        self.init(frame: frame)
        
        self.setImage(normaImage, for: .normal)
        self.setImage(pressedImage, for: .highlighted)
        self.setTitle(normalTitle, for: .normal)
        self.setTitle(pressedTitle, for: .highlighted)
    }
    
    public func addTarget(_ target: Any?, action: Selector) {
        var controlEvent = UIControlEvents.touchUpInside
        #if TARGET_OS_TV
            controlEvent = .primaryActionTriggered
        #endif
        self.addTarget(target, action: action, for: controlEvent)
    }
    
    public func setTitle(_ title: String?) {
        setTitle(title, for: .normal)
    }
    
    public func setTitleColor(_ color: UIColor?) {
        setTitleColor(color, for: .normal)
        setTitleColor(color?.blend(withColor: .black, alpha: 0.48), for: .highlighted)
    }
    
    public func setImage(_ image: UIImage?) {
        setImage(image, for: .normal)
    }
    
    public func setBackgroundImage(_ image: UIImage?) {
        setBackgroundImage(image, for: .normal)
    }
    
    public func registerBorderColorEvents() {
        addTarget(self, action: #selector(selfTouchUpInside(sender:)),      for: .touchUpInside)
        addTarget(self, action: #selector(selfTouchDown(sender:)),          for: .touchDown)
        addTarget(self, action: #selector(selfTouchDragOutside(sender:)),   for: .touchDragOutside)
        addTarget(self, action: #selector(selfTouchDragInside(sender:)),    for: .touchDragInside)
    }
    
    // MARK: Actions
    
    @objc private func selfTouchUpInside(sender: UIButton) {
        sender.layer.borderColor = sender.titleColor(for: .normal)?.cgColor
    }
    
    @objc private func selfTouchDown(sender: UIButton) {
        sender.layer.borderColor = sender.titleColor(for: .highlighted)?.cgColor
    }
    
    @objc private func selfTouchDragOutside(sender: UIButton) {
        sender.layer.borderColor = sender.titleColor(for: .normal)?.cgColor
    }
    
    @objc private func selfTouchDragInside(sender: UIButton) {
        sender.layer.borderColor = sender.titleColor(for: .highlighted)?.cgColor
    }
    
}
