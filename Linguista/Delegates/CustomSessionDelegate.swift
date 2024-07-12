//
//  CustomSessionDelegate.swift
//  Linguista
//
//  Created by Daniel Grant on 7/9/24.
//

import Foundation
class CustomSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Trust the certificate for localhost
        if challenge.protectionSpace.host == "localhost" {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
