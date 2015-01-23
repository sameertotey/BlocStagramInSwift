//
//  LoginViewController.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/23/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Foundation

let ReceivedInstagramAccessToken = "com.sameertotey.receivedInstagramAccessToken"

class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let urlString = "https://instagram.com/oauth/authorize/?client_id=\(DataSource.SharedInstanceStore.instagramClientID)&redirect_uri=\(redirectURI())&response_type=token"
        
        if let url = NSURL(string: urlString) {
            var request = NSMutableURLRequest(URL: url)
            self.webView.loadRequest(request)
        }
    }

    func redirectURI() -> String {
        return "http://sameertotey.com"
    }
    
    deinit {
        // Removing this line causes a weird flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
        clearInstagramCookies()
    
        // see https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1
        self.webView.delegate = nil;
    }
    
    /**
    Clears Instagram cookies. This prevents caching the credentials in the cookie jar.
    */
    func clearInstagramCookies() {
        for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
            if let domainrange = cookie.domain.rangeOfString("instagram.com") {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie as NSHTTPCookie)
            }
        }
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString: NSString = request.URL.absoluteString!
        if urlString.hasPrefix(redirectURI()) {
            // This contains our auth token
            let rangeOfAccessTokenParameter = urlString.rangeOfString("access_token=")
            let indexOfTokenStarting: Int = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
            let accessToken = urlString.substringFromIndex(indexOfTokenStarting)
            NSNotificationCenter.defaultCenter().postNotificationName(ReceivedInstagramAccessToken, object:accessToken)
            return false
        }
        return true;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
