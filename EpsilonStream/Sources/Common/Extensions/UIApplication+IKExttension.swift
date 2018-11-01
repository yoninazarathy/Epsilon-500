import UIKit

private struct UIApplicationExtensionProperties {
    static fileprivate var idleTimerDisabledCounter = 0
}

extension UIApplication {
    
    private func refreshIdleTimerDisabled() {
        UIApplication.shared.isIdleTimerDisabled = (UIApplicationExtensionProperties.idleTimerDisabledCounter > 0)
    }
    
    public func incrementIdleTimerDisabled() {
        UIApplicationExtensionProperties.idleTimerDisabledCounter += 1
        refreshIdleTimerDisabled()
    }
    
    public func decrementIdleTimerDisabled() {
        UIApplicationExtensionProperties.idleTimerDisabledCounter -= 1
        refreshIdleTimerDisabled()
    }
    
}
