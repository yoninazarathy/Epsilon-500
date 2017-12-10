import UIKit

protocol ViewRefreshProtocol {
    var animationDuration: TimeInterval { get }
    
    func initialize()
    func refresh()
    func refreshPhone()
    func refreshPad()
    func refreshForDevice()
    func refreshAnimated(withDuration duration: TimeInterval, completion: ((Bool) -> Void)?)
    func refreshAnimated(withCompletion completion: ((Bool) -> Void)?)
}

extension ViewRefreshProtocol {
    
    var animationDuration: TimeInterval {
        return 0.2
    }
    
    func refreshAnimated(withDuration duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.refresh()
        }, completion: completion)
    }
    
    func refreshAnimated(withCompletion completion: ((Bool) -> Void)? = nil) {
        refreshAnimated(withDuration: animationDuration, completion:  completion)
    }
    
    func refreshPhone() {
        
    }
    
    func refreshPad() {
        
    }
    
    func refreshForDevice() {
        if IsPad() {
            refreshPad()
        } else {
            refreshPhone()
        }
    }
    
}

class BaseView: UIView, ViewRefreshProtocol {
    
    // MARK: - Properties
    
    override var frame: CGRect {
        didSet {
            if frame != oldValue {
                refresh()
            }
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.initialize()
    }
    
    func initialize() {
        
    }
    
    // MARK: - Methods

    // layoutSubviews() method sometimes is called unexpectedly. So better don't refresh here.
//    public override func layoutSubviews() {
//        refresh()
//    }
    
    func refresh() {
    
    }
    
    func refreshPhone() {
        
    }
    
    func refreshPad() {
        
    }
}
