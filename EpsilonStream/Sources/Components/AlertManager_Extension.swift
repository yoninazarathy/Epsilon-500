import UIKit

// Add custom alert methods here

extension AlertManager {
    
    func showWait() {
        showAlert(key: "showWait", title: LocalString("AlertWaitTitle"), message: nil, buttonTitles: [])
    }
    
    func closeWait() {
        closeAlert(key: "showWait")
    }
    
    func showTextField(withText text: String, placeholder: String? = nil, message: String?, keyboardType: UIKeyboardType = UIKeyboardType.default,
                       confirmation: @escaping ( (Bool, String?) -> () ) ) {
        var alertTextField: UITextField!
        
        let configuration = { (alert: UIAlertController) in
            alert.addTextField { (textField) in
                textField.text = text
                textField.placeholder = placeholder
                textField.keyboardType = keyboardType
                alertTextField = textField
            }
        }
        
        showAlert(key: "showTextField", message: message, cancelButtonTitle: AlertManager.defaultCancelButtonTitle,
                  okButtonTitle: AlertManager.defaultOKButtonTitle, configuration: configuration, confirmation: { (confirmed, _) in
                    confirmation(confirmed, alertTextField.text)
        })
    }
    
    func showResumePlayback(seconds: Int, confirmation: @escaping AlertConfirmation) {
        let message = String(format: LocalString("AlertResumePlaybackMessage"), TextManager.shared.minutesSeconds(fromSeconds: seconds))
        let alert = showAlert(key: "showResumePlayback", message: message, cancelButtonTitle: LocalString("AlertResumePlaybackCancelButton"),
                              okButtonTitle: LocalString("AlertResumePlaybackOKButton"), confirmation: confirmation)
        alert.preferredAction = alert.actions[1]
    }
    
    func showStartCreateMathObjectLink(confirmation: @escaping AlertConfirmation) {
        showAlert(key: "showStartCreateMathObjectLink", message: LocalString("AlertStartCreateMathObjectLinkMessage"),
                  cancelButtonTitle: LocalString("CommonTextNo"), okButtonTitle: LocalString("CommonTextYes"), confirmation: confirmation)
    }

    func showFinishCreateMathObjectLink(hashtag: String, searchText: String, confirmation: @escaping AlertConfirmation) {
        let message = String(format: LocalString("AlertFinishCreateMathObjectLinkMessage"), hashtag, searchText)
        showAlert(key: "showFinishtCreateMathObjectLink", message: message,
                  cancelButtonTitle: LocalString("CommonTextNo"), okButtonTitle: LocalString("CommonTextYes"), confirmation: confirmation)
    }
    
    func showEditMOLinkTitleAndSubtitle(withTitle title: String, subtitle: String, confirmation: @escaping ( (String?, String?) -> () ) ) {
        var titleTextField: UITextField!
        var subtitleTextField: UITextField!
        
        let configuration = { (alert: UIAlertController) in
            alert.addTextField { (textField) in
                textField.placeholder = LocalString("AlertEditMOLinkTitleAndSubtitleTitlePlaceholder")
                textField.text = title
                titleTextField = textField
            }
            alert.addTextField { (textField) in
                textField.placeholder = LocalString("AlertEditMOLinkTitleAndSubtitleSubtitlePlaceholder")
                textField.text = subtitle
                subtitleTextField = textField
            }
        }
        
        showAlert(key: "showEditMOLinkTitleAndSubtitleAlert", message: LocalString("AlertEditMOLinkTitleAndSubtitleMessage"),
                  okButtonTitle: AlertManager.defaultOKButtonTitle, configuration: configuration, confirmation: { (_, _) in
                    
                   confirmation(titleTextField.text, subtitleTextField.text)
        })
        
    }
    
    func showSelectMOLinkImageURL(withURLAliases urlAliases: [String], confirmation: @escaping AlertConfirmation) {
        var buttonTitles = urlAliases
        buttonTitles.append(AlertManager.defaultCancelButtonTitle)
        
        showAlert(key: "showSelectMOLinkImageURL", title: LocalString("AlertSelectMOLinkImageURLTitle"), preferredStyle: .actionSheet,
                  buttonTitles: buttonTitles, cancelButtonIndex: buttonTitles.count - 1, confirmation: confirmation)
    }
}
