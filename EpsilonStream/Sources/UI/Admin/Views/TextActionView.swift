import UIKit


class TextActionView: BaseView {
    // MARK: - Model
    
    var text: String? {
        didSet {
            if text != oldValue {
                refresh()
            }
        }
    }
    
    var buttonTitle: String? {
        didSet {
            if buttonTitle != oldValue {
                refresh()
            }
        }
    }
    
    var buttonIsEnabled = true {
        didSet {
            if buttonIsEnabled != oldValue {
                refresh()
            }
        }
    }
    
    var action: ( () -> () )?
    
    // MARK: - UI
    
    let label = UILabel()
    let button = ViewFactory.shared.roundedRectButton(withColor: .blue)
    
    override func initialize() {
        super.initialize()
        
        label.numberOfLines = -1
        addSubview(label)
        
        button.addTarget(self, action: #selector(buttonPressed(sender:)))
        addSubview(button)
    }
    
    override func refresh() {
        super.refresh()
        
        button.isEnabled = buttonIsEnabled
        button.alpha = buttonIsEnabled ? 1 : 0.5
        let gap = CGFloat(10)
        button.setTitle(buttonTitle)
        var size = CGSize(width: 80, height: 40)
        var origin = CGPoint(x: button.superview!.bounds.width - size.width - gap, y: (button.superview!.bounds.height - size.height) / 2)
        button.frame = CGRect(origin: origin, size: size)
        
        label.text = text
        origin = CGPoint(x: gap, y: 0)
        size = CGSize(width: button.frame.origin.x - 2 * origin.x, height: bounds.size.height)
        label.frame = CGRect(origin: origin, size: size)
    }
    
    // MARK: - Actions
    
     @objc func buttonPressed(sender: UIButton) {
        action?()
    }
}
