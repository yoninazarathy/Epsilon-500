import UIKit

class AlertRootViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIViewController.currentViewController().preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return UIViewController.currentViewController().prefersStatusBarHidden
    }
}

// Declare a global var to produce a unique address as the assoc object handle
private var alertWindowAssociatedObjectKey: UInt8 = 0

extension UIAlertController {
    
    private var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &alertWindowAssociatedObjectKey) as? UIWindow
        }
        set {
            objc_setAssociatedObject(self, &alertWindowAssociatedObjectKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
   
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Precaution to insure window gets destroyed.
        self.alertWindow?.isHidden = true
        self.alertWindow = nil
    }
    
    public func show(animated: Bool = true) {
        self.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        self.alertWindow!.rootViewController = AlertRootViewController()
        // We inherit the main window's tintColor.
        self.alertWindow!.tintColor = UIApplication.shared.keyWindow?.tintColor;
        // and display new window above everything.
        self.alertWindow!.windowLevel = UIWindowLevelAlert + 1;
        
        self.alertWindow!.makeKeyAndVisible()
        
        self.alertWindow!.rootViewController?.present(self, animated: true, completion: nil)
    }
    
}
