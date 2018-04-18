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

}
