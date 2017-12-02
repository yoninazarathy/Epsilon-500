import Foundation

extension CachedURLResponse {
    
    // https://stackoverflow.com/questions/19855280/how-to-set-nsurlrequest-cache-expiration#
    func withExpirationDuration(duration: Double) -> CachedURLResponse {
        let httpResponse = self.response as? HTTPURLResponse
        guard httpResponse != nil else {
            return self
        }
        
        var headers = httpResponse!.allHeaderFields
        
        headers["Cache-Control"] = "max-age=\(duration)"
        headers["Expires"] = nil
        headers["s-maxage"] = nil
        
        let newResponse = HTTPURLResponse(url: httpResponse!.url!, statusCode: httpResponse!.statusCode, httpVersion: "HTTP/1.1",
                                          headerFields: headers as? [String: String])
     
        return CachedURLResponse(response: newResponse!, data: self.data, userInfo: headers, storagePolicy: self.storagePolicy)
    }
    
}
