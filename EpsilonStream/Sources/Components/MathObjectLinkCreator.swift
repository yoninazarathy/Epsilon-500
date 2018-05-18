import Foundation

enum MathObjectLinkCreatorState {
    case initial
    case enterSearchTerm
    case finishCreation
}

class MathObjectLinkCreator: NSObject {
    var state = MathObjectLinkCreatorState.initial {
        didSet {
            if state != oldValue {
                didChangeState?()
            }
        }
    }
    var didChangeState: (() -> Void)?
    
    var hashTag = "" {
        didSet {
            if hashTag != oldValue {
                didChangeHashTag?()
            }
        }
    }
    var didChangeHashTag: (() -> Void)?
    
    var searchString = "" {
        didSet {
            if searchString != oldValue {
                didChangeSearchString?()
            }
        }
    }
    var didChangeSearchString: (() -> Void)?
}
