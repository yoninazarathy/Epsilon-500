import UIKit
import WebKit

class SnippetViewController: BaseViewController, WKNavigationDelegate {
    // MARK: - Model
    
    var snippet: Snippet!
    
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
        
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalString("CommonTextClose"), style: .plain,
                                                               target: self, action: #selector(close))
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
    
    func setValuesInWebView() {
        //        let title = "How can a fraction be converted to a percent?"
        //        let body = "A cone is a [solid](solid) with a circular base and one [vertex](vertex).\\n\\nTwo cones are shown below.\\n\\n![image1]"//"There are many ways to convert a [decimal number](decimal) $x^2$![image1]"
        //        let imageURL = "https://es-app.com/snippet-assets/convertFractionToPercent.svg"
        
        let title = snippet.title
        var body = snippet.body
        body = body.replacingOccurrences(of: "\\", with: "\\\\") //to allow \ inside string passed to JS (latex commands)
        body = body.replacingOccurrences(of: "\"", with: "\\\"") //to allow " inside string passed to JS
        body = body.replacingOccurrences(of: "\n", with: "\\n ") //to allow \n inside string passed to JS
//        print(body)
        let imageURL = snippet.imageURL
        
        webView.evaluateJavaScript(jsString(parameterName: "Title", value: title)) { (_, _) in
            self.webView.evaluateJavaScript(self.jsString(parameterName: "Snippet", value: body)) { (_, _) in
                self.webView.evaluateJavaScript(self.jsString(parameterName: "Image", value: imageURL))
            }
        }
    }
    
    func refreshWebViewAppearance( completion: @escaping () -> Void) {
        webView.evaluateJavaScript("document.getElementsByClassName(\"App-header\")[0].style.backgroundColor=\"white\"") { (_, _) in
            self.webView.evaluateJavaScript("document.getElementsByClassName(\"App-header\")[0].style.color=\"black\"", completionHandler: { (_, _) in
                completion()
            })
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshWebViewAppearance {
            self.setValuesInWebView()
        }
    }
}
