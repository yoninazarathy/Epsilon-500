import UIKit

func DLog(_ format: String, _ args: CVarArg...) {
    #if DEBUG
        NSLog(format, args)
    #endif
}

public func LocalString(_ key: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: key, table: "")
}

public func IsPhone() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .phone
}

public func IsPad() -> Bool {
    return UI_USER_INTERFACE_IDIOM() == .pad
}

class Common: NSObject {
    
    // MARK: - Required properties
    
    private static var privateWindow: UIWindow?
    public static var window: UIWindow? {
        set {
            privateWindow = newValue
        }
        get {
            if privateWindow != nil {
                return privateWindow
            }
            return UIApplication.shared.keyWindow
        }
    }
    
    // MARK: - App Info
    
    public static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    public static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    public static var buildVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    // MARK: - Device
    
    public static var is64Bit: Bool {
        return MemoryLayout<Int>.size == MemoryLayout<Int64>.size
    }
    
    public static var isIPhoneX: Bool {
        var result = false
        
        if #available(iOS 11.0, *) {
            let safeAreaInsets = window?.safeAreaInsets
            if safeAreaInsets != nil && ( (window?.safeAreaInsets.top)! > CGFloat(0) || window?.safeAreaInsets != .zero) {
                result = true
            }
        }
        
        return result
    }
    
    // MARK: - Threads
    
    private static let concurrentQueue = DispatchQueue(label: "backgroundConcurrentQueue", attributes: .concurrent)
    public static func performInBackground(closure: @escaping () -> Void, completion: (() -> Void)? = nil) {
        concurrentQueue.async {
            closure()
            if completion != nil {
                performOnMainThread(closure: completion!)
            }
        }
        
        // http://stackoverflow.com/questions/24056205/how-to-use-background-thread-in-swift
        //        DispatchQueue.global(qos: .background).async {
        //            closure()
        //            if completion != nil {
        //                performOnMainThread(closure: completion!)
        //            }
        //        }
    }
    
    public static func performInBackground(closure: @escaping () -> Void) { // Need separate method to allow shorten closure code.
        performInBackground(closure: closure, completion:  nil)
    }
    
    public static func performOnMainThread(delay: TimeInterval? = nil, closure: @escaping () -> Void ) {
        // http://stackoverflow.com/questions/24985716/in-swift-how-to-call-method-with-parameters-on-gcd-main-thread
        
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
    
}

