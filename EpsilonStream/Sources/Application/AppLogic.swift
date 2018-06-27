import UIKit

class AppLogic: NSObject {
    static let shared = AppLogic()
    
    let viewControllerManager = ViewControllerManager()
    
    override init() {
        super.init()
    }
    
    func editMathObjectLink(_ mathObjectLink: MathObjectLink) {
        let viewController = MathObjectLinkEditViewController()
        viewControllerManager.openViewController(viewController)
    }
}
