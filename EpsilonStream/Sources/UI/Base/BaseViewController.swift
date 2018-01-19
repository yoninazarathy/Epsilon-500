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
        //refresh()
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
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if IsPad() {
//            return .all
//        }
//        return .portrait
//    }
    
    // MARK: - Keyboard
    func registerKeyboardNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),  name: .UIKeyboardWillShow,  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)),   name: .UIKeyboardDidShow,   object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),  name: .UIKeyboardWillHide,  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)),   name: .UIKeyboardDidHide,   object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)),
                                               name: .UIKeyboardDidChangeFrame,    object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow,          object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow,           object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide,          object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide,           object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidChangeFrame,    object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {

    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        keyboardFrame = .zero
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        
    }
    
    @objc func keyboardDidChangeFrame(notification: Notification) {
        if let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardFrame = frame
            //DLog("keyboardFrame: %@", NSStringFromCGRect(keyboardFrame))
        }
    }
}
