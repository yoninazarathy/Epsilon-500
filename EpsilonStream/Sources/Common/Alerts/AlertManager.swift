import UIKit

typealias AlertConfirmation = (Bool, Int) -> Void

class AlertManager: NSObject {
    static let shared = AlertManager()
    var alerts = [String: UIAlertController]()
    var alertConfirmations = [String: AlertConfirmation]()
    
    // MARK: - Properties
    static var defaultCancelButtonTitle: String {
        return LocalString("AlertDefaultCancelButton")
    }
    
    static var defaultOKButtonTitle: String {
        return LocalString("AlertDefaultOKButton")
    }
    
    static var defaultCloseButtonTitle: String {
        return LocalString("AlertDefaultCloseButton")
    }
    
    static var defaultErrorTitle: String {
        return LocalString("AlertErrorTitle")
    }
    
    static var defaultTitle: String {
        return "Epsilon Stream"
        //return Common.appName
    }
    
    // MARK: - Methods
    
    func showAlert(_ alert: UIAlertController, key: String, confirmation: AlertConfirmation? = nil) {
        if alerts[key] == nil {
            alerts[key] = alert
            alertConfirmations[key] = confirmation
            
            alert.show()
        }
    }
    
    func closeAlert(_ alert: UIAlertController, buttonIndex: Int) {
        alert.dismiss(animated: true, completion: nil)
        
        var alertKey: String?
        
        for (key, value) in alerts {
            if value == alert {
                alertKey = key
                break
            }
        }
        
        if let key = alertKey {
            alerts[key] = nil
            
            let confirmation = alertConfirmations[key]
            if confirmation != nil {
                let confirmed = (alert.actions[buttonIndex].style != .cancel)
                confirmation?(confirmed, buttonIndex)
                
                alertConfirmations[key] = nil
            }
        }
    }
    
    func closeAlert(key: String) {
        let alert = alerts[key]
        if alert != nil {
            alertConfirmations[key] = nil // don't fire confirmation block if alert was dismissed programmatically
            closeAlert(alert!, buttonIndex: 0)
        }
    }
    
    @discardableResult public func showAlert(key: String, title: String = defaultTitle, message: String? = nil,
                                             preferredStyle: UIAlertControllerStyle = .alert, buttonTitles: [String],
                                             cancelButtonIndex: Int = 0, configuration: ((UIAlertController)->())? = nil,
                                             confirmation: AlertConfirmation? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (idx, title) in buttonTitles.enumerated() {
            let style = (idx == cancelButtonIndex) ? UIAlertActionStyle.cancel : UIAlertActionStyle.default
            alert.addAction(UIAlertAction(title: title, style: style, handler: { (action) in
                self.closeAlert(alert, buttonIndex: idx)
            }))
        }
        
        configuration?(alert)
        showAlert(alert, key: key, confirmation: confirmation)
        
        return alert
    }
    
    @discardableResult public func showAlert(key: String, title: String = defaultTitle, message: String? = nil,
                                             preferredStyle: UIAlertControllerStyle = .alert,
                                             cancelButtonTitle: String? = nil, okButtonTitle: String? = nil,
                                             configuration: ((UIAlertController)->())? = nil,
                                             confirmation: AlertConfirmation? = nil) -> UIAlertController {
        
        var buttonTitles = [String]()
        if cancelButtonTitle?.isEmpty == false {
            buttonTitles.append(cancelButtonTitle!)
        }
        if okButtonTitle?.isEmpty == false {
            buttonTitles.append(okButtonTitle!)
        }
        
        return showAlert(key: key, title: title, message: message, buttonTitles: buttonTitles, configuration: configuration, confirmation: confirmation)
    }
    
    public func showError(message: String, confirmation: AlertConfirmation? = nil) {
        showAlert(key: UUID().uuidString, title: AlertManager.defaultErrorTitle, message: message, cancelButtonTitle: AlertManager.defaultCloseButtonTitle,
                  okButtonTitle: nil, confirmation: confirmation)
    }
    
    public func showError(error: Error, confirmation: AlertConfirmation? = nil) {
        showError(message: error.localizedDescription, confirmation: confirmation)
    }
}

