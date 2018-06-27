import UIKit

class ViewControllerManager: NSObject {

    private var rootNavigationController: UINavigationController {
        //DLog("\(UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController)")
        return UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController as! UINavigationController
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
