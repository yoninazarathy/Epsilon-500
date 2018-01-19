import UIKit

extension String {
    
    public func size(withConstrainedWidth width: CGFloat = .greatestFiniteMagnitude, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingRect = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return boundingRect.size
    }
    
    // MARK: - Substring
    // https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift-3
    // https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
    
    func index(offsetBy n: Int) -> Index {
        return index(startIndex, offsetBy: n)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(offsetBy: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(offsetBy: r.lowerBound)
        let endIndex = index(offsetBy: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
}
