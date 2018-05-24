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
    
    var actionButtonIsEnabled = true {
        didSet {
            if actionButtonIsEnabled != oldValue {
                refresh()
            }
        }
    }
    
    var action: ( () -> () )?
    var closeAction: ( () -> () )?
    
    // MARK: - UI
    
    private let label = UILabel()
    private let actionButton = ViewFactory.shared.roundedRectButton(withColor: .blue)
    private let closeButton = UIButton(frame: .zero, normaImage: #imageLiteral(resourceName: "EraseIconSmall"))
    
    override func initialize() {
        super.initialize()
        
        label.numberOfLines = -1
        addSubview(label)
        
        actionButton.addTarget(self, action: #selector(actionButtonPressed(sender:)) )
        addSubview(actionButton)
        
        closeButton.sizeToFit()
        closeButton.addTarget(self, action: #selector(closeButtonPressed(sender:)) )
        addSubview(closeButton)
    }
    
    override func refresh() {
        super.refresh()
        
        let gap = CGFloat(10)
        var size = closeButton.bounds.size
        var origin = CGPoint(x: closeButton.superview!.bounds.width - size.width - gap, y: (closeButton.superview!.bounds.height - size.height) / 2)
        closeButton.frame = CGRect(origin: origin, size: size)
        
        actionButton.isEnabled = actionButtonIsEnabled
        actionButton.alpha = actionButtonIsEnabled ? 1 : 0.1
        actionButton.setTitle(buttonTitle)
        size = CGSize(width: 80, height: 40)
        origin = CGPoint(x: closeButton.frame.origin.x - size.width - gap, y: (actionButton.superview!.bounds.height - size.height) / 2)
        actionButton.frame = CGRect(origin: origin, size: size)
        
        label.text = text
        origin = CGPoint(x: gap, y: 0)
        size = CGSize(width: actionButton.frame.origin.x - 2 * origin.x, height: bounds.size.height)
        label.frame = CGRect(origin: origin, size: size)
    }
    
    // MARK: - Actions
    
    @objc func actionButtonPressed(sender: UIButton) {
        action?()
    }
    
    @objc func closeButtonPressed(sender: UIButton) {
        closeAction?()
    }
}
