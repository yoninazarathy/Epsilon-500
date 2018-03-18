import UIKit
import Alamofire

typealias AssetManagerCompletion = (URL?, Error?) -> Void

@objcMembers class UrlAssetItem: NSObject {
    var url: String?
    var md5: String?
    
    var path: String?
    
    var fileExists: Bool {
        if path == nil {
            return false
        }
        return IKFileManager.shared.fileExists(atPath: path!)
    }
}

class AssetManager: NSObject {
    public static let shared = AssetManager()
    
    private var completionsForURLs = [URL: [AssetManagerCompletion] ]()
    
    // Returns "true" if file exists at the path. "Completion" is called only if the file needs to be downloaded.
    func downloadFile(at url: URL, to fileURL: URL, completion: AssetManagerCompletion? = nil) -> Bool {
        
        if IKFileManager.shared.fileExists(atURL: fileURL) == true {
            return true
            
        } else {
            
            var startNewDownload = true
            if completion != nil {
                if  completionsForURLs[url] == nil  {
                    completionsForURLs[url] = [AssetManagerCompletion]()
                } else {
                    startNewDownload = false
                }
                completionsForURLs[url]?.append(completion!)
            }

            guard startNewDownload == true else {
                return false
            }
            
            //
            DLog("Downloading file at URL: \(url)")
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(url, to: destination).response(completionHandler: { (response) in
                Common.performOnMainThread {
                    let completions = self.completionsForURLs[url]
                    if completions != nil {
                        for completion in completions! {
                            completion(fileURL, response.error)
                        }
                        self.completionsForURLs[url] = nil
                    }
                }
            })
        
        }
        
        return false
    }
}
