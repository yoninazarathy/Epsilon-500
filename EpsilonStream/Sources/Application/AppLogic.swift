import UIKit

class AppLogic: NSObject {
    static let shared = AppLogic()
    
    let viewControllerManager = ViewControllerManager()
    
    override init() {
        super.init()
    }
    
    func editMathObjectLink(_ mathObjectLink: MathObjectLink) {
        let viewController = MathObjectLinkEditViewController()
        viewController.mathObjectLink = mathObjectLink
        viewControllerManager.openViewController(viewController)
    }
    
    func openSnippet(_ snippet: Snippet) {
        let viewController = SnippetViewController()
        viewController.snippet = snippet
        if UIDevice.current.userInterfaceIdiom == .pad {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .formSheet
            viewControllerManager.openModalViewController(navigationController)
        } else {
            viewControllerManager.openViewController(viewController)
        }
    }
}
