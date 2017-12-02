import UIKit

extension UIViewController {

    private static func findCurrrentViewController(for viewController: UIViewController) -> UIViewController {
        var resultViewController = viewController;
        
        if viewController.presentedViewController != nil {
            // Ignore UIAlertController.
            if viewController.presentedViewController is UIAlertController == false {
                // Return presented view controller
                resultViewController = UIViewController.findCurrrentViewController(for: viewController.presentedViewController!)
            }
        } else if viewController is UISplitViewController {
            
            // Return right hand side.
            let splitViewController = viewController as! UISplitViewController
            if splitViewController.viewControllers.count > 0 {
                resultViewController = UIViewController.findCurrrentViewController(for: splitViewController.viewControllers.last!)
            }
            
        } else if viewController is UINavigationController {
            
            // Return top view.
            let navigationController = viewController as! UINavigationController
            if navigationController.viewControllers.count > 0 {
                resultViewController = UIViewController.findCurrrentViewController(for: navigationController.topViewController!)
            }
            
        } else if viewController is UITabBarController {
            
            // Return visible view.
            let tabBarController = viewController as! UITabBarController
            if tabBarController.viewControllers!.count > 0 {
                resultViewController = UIViewController.findCurrrentViewController(for: tabBarController.selectedViewController!)
            }
            
        }
        
        return resultViewController;
    }
    
    public static func currentViewController() -> UIViewController {
        let viewController = UIApplication.shared.windows.first!.rootViewController
        return UIViewController.findCurrrentViewController(for: viewController!)
    }

}
