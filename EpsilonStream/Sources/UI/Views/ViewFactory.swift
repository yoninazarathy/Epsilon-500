import UIKit

class ViewFactory: NSObject {
    static let shared = ViewFactory()
    
    func refreshScrollViewInsets(scrollView: UIScrollView, withKeyboardFrame keyboardFrame: CGRect) {
        // Assuming that scroll view is at the bottom.
        var bottomInset = keyboardFrame.size.height;
        if #available(iOS 11, *) {
            if (bottomInset != 0) {
                var superview = scrollView.superview;
                while (superview != nil) {
                    if (superview!.safeAreaInsets.bottom != 0) {
                        bottomInset -= superview!.safeAreaInsets.bottom;
                        break;
                    }
                    superview = superview!.superview;
                }
                }
        }
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    }
    
}
