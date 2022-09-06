//
//  AuthViewController.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import UIKit
import WebKit

final class AuthViewController: UIViewController, WKNavigationDelegate{
    
    // MARK: - Properties
    
    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero,configuration: config)
        return webView
    }()
    
    public var completionHandler: ((Bool)->Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInURL else{
            return
        }
        webView.load(URLRequest(url: url))
    }
        
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url=webView.url else{
            return
        }
        //Exchange code for access token
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else{
            return
        }
        webView.isHidden = true
        print("Code: \(code)")
        AuthManager.shared.exchangeCodeForToken(code: code){[weak self]success in
            DispatchQueue.main.async{
                self?.tabBarController?.moreNavigationController.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame=view.bounds
    }
}