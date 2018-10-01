import UIKit
import FirebaseAnalytics

class AppLogic: NSObject {
    static let shared = AppLogic()
    
    let viewControllerManager = ViewControllerManager()
    
    override init() {
        super.init()
    }
    
    func openVideoItem(_ item: VideoSearchResultItem) {
        Analytics.logEvent("video_play", parameters: ["videoId" : item.youtubeId as NSObject])
        
        let secondsWatched = UserDataManager.getSecondsWatched(forKey: item.youtubeId)
        
        let playVideo = { (resumeSeconds: Int) -> Void in
            let vc = PlayVideoViewController()
            vc.isExplodingDots = false //QQQQ read type of video display here
            vc.videoIdToPlay = item.youtubeId
            vc.startSeconds = resumeSeconds
            //self.navigationController?.pushViewController(vc, animated: true)
            self.viewControllerManager.openViewController(vc)
        }
        
        if secondsWatched > 0 {
            
            AlertManager.shared.showResumePlayback(seconds: secondsWatched, confirmation: { (confirmed, _) in
                if confirmed {
                    playVideo(secondsWatched)
                } else {
                    playVideo(0)
                }
            })
            
        } else {
            
            playVideo(0)
            
        }
        
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
