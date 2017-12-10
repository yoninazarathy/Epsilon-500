import UIKit

class BaseViewController: UIViewController, ViewRefreshProtocol {
    
    // MARK: - Model
    
    var animationDuration: TimeInterval = 0.2
    var isViewDisplayed: Bool = false
    var keyboardFrame: CGRect = CGRect.zero
    var isRotating = false
    
    var shouldRefresh: Bool {
        return (isViewLoaded == true) && (isViewDisplayed == true)
    }
    
    var statusBarFrame: CGRect {
        if (prefersStatusBarHidden == true) {
            return CGRect.zero
        }
        return UIApplication.shared.statusBarFrame
    }
    
    var keyboardIsDisplayed: Bool {
        return keyboardFrame.equalTo(CGRect.zero) == false
    }
    
//    var navigationBarIsDisplayed: Bool {
//        return true
//    }
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {

    }
    
//    deinit {
//        DLog("deinit")
//    }
    
    // MARK: - View methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isViewDisplayed = true
        refresh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewDisplayed = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if ( (view.layer.animationKeys() == nil) || (view.layer.animationKeys()?.count == 0) || (isRotating == true) ) {
            // "viewWillLayoutSubviews" is also called when animation is running.
            // And we prevent "refreshView" call during animation.
            refresh()
            isRotating = false
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view.clipsToBounds = true
    }
    
    func refresh() {
    
    }
    
    func refreshPhone() {
        
    }
    
    func refreshPad() {
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with:  coordinator)
        isRotating = true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if IsPad() {
            return .all
        }
        return .portrait
    }
}
