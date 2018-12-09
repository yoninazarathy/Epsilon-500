import UIKit

class ViewControllerManager: NSObject {
    
    override init() {
        super.init()
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barStyle = .blackTranslucent // Need this for white status bar.
        navigationBar.barTintColor = navigationBarColor
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
    }
    
    private lazy var navigationBarColor: UIColor = {
        return UIColor(rgb: ES_watch1)
    }()
    
    private var rootNavigationController: UINavigationController {
        //DLog("\(UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController)")
        let navigationController = UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController as! UINavigationController
//        navigationController.navigationBar.barStyle = .blackTranslucent // Need this for white status bar.
//        navigationController.navigationBar.barTintColor = navigationBarColor
//        navigationController.navigationBar.isTranslucent = false
//        navigationController.navigationBar.tintColor = .white
        
        return navigationController
    }
    
    func openViewController(_ viewController: UIViewController, animated: Bool = true) {
        if rootNavigationController.topViewController != viewController {
            if rootNavigationController.viewControllers.contains(viewController) {
                rootNavigationController.popToViewController(viewController, animated: true)
            } else {
                rootNavigationController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func openModalViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        rootNavigationController.present(viewController, animated: animated, completion: completion)
    }
    
    func closeViewController(_ viewController: UIViewController, animated: Bool = true) {
        if rootNavigationController.topViewController == viewController {
            rootNavigationController.popViewController(animated: animated)
        } else {
            viewController.dismiss(animated: animated, completion: nil)
        }
    }
}
