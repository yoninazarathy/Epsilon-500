import UIKit

public struct RGBAColor {
    var r = CGFloat(0)
    var g = CGFloat(0)
    var b = CGFloat(0)
    var a = CGFloat(1)
    
    mutating func fromHexString(_ hexString: String) {
        var array: [CGFloat] = [0, 0, 0, 1]
        
        
        let strlen = hexString.characters.count
        var start = hexString.startIndex
        let lastIndex = strlen > 0 ? hexString.index(before: hexString.endIndex) : hexString.startIndex
        let count = min((strlen + 1) / 2, array.count)
        
        
        
        for i in 0 ..< count  {
            start = i > 0 ? hexString.index(start, offsetBy: 2) : start
            let end = start < lastIndex ? hexString.index(after: start) : start
            let str = hexString[start...end]
            
            if let value = UInt8(str, radix: 16) {
                array[i] = CGFloat(value) / 255.0
            }
        }
        
        r = array[0]
        g = array[1]
        b = array[2]
        a = array[3]
    }
    
    func toHexString() -> String {
        let array = [r, g, b, a]
        var hexString = ""
        
        for i in 0 ..< array.count {
            let value = Int(array[i] * 255)
            var string = String(format: "%2X", value)
            if string[string.startIndex] == " " {
                string.replaceSubrange(string.startIndex...string.startIndex, with: "0")
            }
            hexString += string
        }
                
        return hexString
    }
}

extension UIColor {
    
    // MARK: Properties
    
    public var rgba: RGBAColor {
        var array: [CGFloat] = [0, 0, 0, 1]
        
        if var components = cgColor.components {
            if components.count == 2 {
                let firstComponent = components.first
                components.insert(firstComponent!, at: 1)
                components.insert(firstComponent!, at: 2)
            }
            for i in 0 ..< components.count {
                array[i] = components[i]
            }
        }
        
        let rgba = RGBAColor(r: array[0], g: array[1], b: array[2], a: array[3])
        return rgba
    }
    
    var hexString: String {
        return self.rgba.toHexString()
    }    
    
    // MARK: init
    
    public convenience init(rgba: RGBAColor) {
        self.init(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }
    
    public convenience init(hexString: String) {
        if hexString.isEmpty {
            self.init()
            return
        }
        
        var rgba = RGBAColor()
        rgba.fromHexString(hexString)
        self.init(rgba: rgba)
    }

    // MARK: Object methods

    public func blend(withColor color: UIColor, alpha: CGFloat) -> UIColor {
        let alpha2 = min(1, max(0, alpha))
        let beta = 1 - alpha2
        let rgba1 = self.rgba
        let rgba2 = color.rgba
        
        var rgba = RGBAColor()
        rgba.r = rgba1.r * beta + rgba2.r * alpha2
        rgba.g = rgba1.g * beta + rgba2.g * alpha2
        rgba.b = rgba1.b * beta + rgba2.b * alpha2
        rgba.a = rgba1.a * beta + rgba2.a * alpha2
        
        return UIColor(rgba: rgba)
    }
    
    // MARK: Class methods
    
    public static func color(hexString: String) -> UIColor {
        if hexString.isEmpty {
            return self.clear
        }
        
        struct ColorCache {
            static var dictionary = [String: UIColor]()
        }
        
        var result = ColorCache.dictionary[hexString]
        if (result == nil) {
            result = UIColor(hexString: hexString)
            ColorCache.dictionary[hexString] = result
            
        }
        return result ?? self.clear;
    }
    
    public static func colors(hexStrings: [String]) -> [UIColor] {
        var colors = [UIColor]()
        for hexString in hexStrings {
            colors.append( UIColor(hexString: hexString) )
        }
        
        return colors
    }
}
