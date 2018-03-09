import UIKit

class TextManager: NSObject {
    static let shared = TextManager()
    
    func minutesSeconds(fromSeconds seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }
}
