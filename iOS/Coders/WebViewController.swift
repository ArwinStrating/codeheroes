//
//  WebViewController.swift
//  Code Heroes
//
//  Created by Arwin Strating on 06-03-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import OAuthSwift
import UIKit
typealias WebView = UIWebView

class WebViewController: OAuthWebViewController {
    
    var targetURL: URL?
    let webView: WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.main.bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    
    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }
    
    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        self.webView.loadRequest(req)
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlString = request.url!.absoluteString
        let redirectUri = "https://m4m-code-heroes.firebaseapp.com/__/auth/handler"
        if let _ =  urlString.range(of: "\(redirectUri)?code=") {
            OAuthSwift.handle(url: request.url!)
            self.dismissWebViewController()
        }
        return true
    }}

