import UIKit
import WebKit

class SnippetViewController: BaseViewController, WKNavigationDelegate {
    // MARK: - Model
    
    let snippetString = "There are many ways to convert a [decimal number](decimal) $x^2$![image1]"
    let snippetImageURLstring = "https://es-app.com/snippet-assets/convertFractionToPercent.svg"
    let snippetTitle = "How can a fraction be converted to a percent?"
    
    // MARK: - UI
    var webView: WKWebView!
    
    // MARK: - Methods
    
    override func initialize() {
        super.initialize()
    }
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        if let path = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "snippetBuild") {
            let urlRequest = URLRequest(url: URL(fileURLWithPath: path))
            webView.load(urlRequest)
        }
    }
    
    override func refresh() {
        guard self.shouldRefresh == true else {
            return
        }
        super.refresh()
        
        webView.frame = view.bounds
    }
    
    func jsString(parameterName: String, value: String) -> String {
        return "window.mdBlock.set\(parameterName)(\"\(value)\")"
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(jsString(parameterName: "Title", value: snippetTitle)) { (_, _) in
            self.webView.evaluateJavaScript(self.jsString(parameterName: "Snippet", value: self.snippetString)) { (_, _) in
                self.webView.evaluateJavaScript(self.jsString(parameterName: "Image", value: self.snippetImageURLstring))
            }
        }
    }

}
