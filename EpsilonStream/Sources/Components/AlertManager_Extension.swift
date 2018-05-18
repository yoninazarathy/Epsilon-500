import UIKit

// Add custom alert methods here

extension AlertManager {
    
    func showWait() {
        showAlert(key: "showWait", title: LocalString("AlertWaitTitle"), message: nil, buttonTitles: [])
    }
    
    func closeWait() {
        closeAlert(key: "showWait")
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
}
