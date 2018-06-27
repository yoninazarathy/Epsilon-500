import UIKit

class BaseViewController: UIViewController, ViewRefreshProtocol {
    
    // MARK: - Model
    
    var animationDuration: TimeInterval = 0.2
    var isViewDisplayed: Bool = false
    var keyboardFrame: CGRect = .zero
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
        return (keyboardFrame.size.height > 0 && view.bounds.intersects(keyboardFrame) );
    }
    
    var showsCustomBackButton: Bool {
        return true
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
        view.backgroundColor = .white
        
        if showsCustomBackButton {
            
            let barButtonItem = UIBarButtonItem(title: LocalString("CommonTextBack"), style: .plain, target: nil, action: nil)
            navigationController?.navigationBar.topItem?.backBarButtonItem = barButtonItem
        }
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
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard
    
    func keyboardFrameUpdated() {
        refresh()
    }
    
    func registerKeyboardNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)),
                                               name: .UIKeyboardDidHide,   object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)),
                                               name: .UIKeyboardDidChangeFrame, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow,          object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow,           object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide,          object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide,           object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame,    object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidChangeFrame,    object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {

    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        if var frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if frame.origin.y >= self.view.bounds.size.height { // Keyboard dissapeared
                frame = .zero
            }
            if keyboardFrame.equalTo(frame) == false {
                keyboardFrame = frame
                //DLog("keyboardFrame: %@", NSStringFromCGRect(keyboardFrame))
                keyboardFrameUpdated()
            }
        }
    }
    
    @objc func keyboardDidChangeFrame(notification: Notification) {
        
    }
}
