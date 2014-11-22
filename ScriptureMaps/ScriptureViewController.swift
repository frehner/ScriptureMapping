//
//  ScriptureViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/22/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class ScriptureViewController : UIViewController, UIWebViewDelegate {
    
    // MARK: - Properties
    var book: Book!
    var chapter = 0
    
    // MARK: - Outlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let html = ScriptureRenderer.sharedRenderer.htmlForBookId(book.id, chapter: chapter)
        //load indicated book/chapter into view
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    // MARK: - Web view delegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.absoluteString?.rangeOfString(ScriptureRenderer.sharedRenderer.BASE_URL) != nil {
            //adjust map to show point at default zoom level. look at id at get it from DB (vid5)
            NSLog("geocoded place \(request)")
            return false
        }
        
        return true
    }
    
}
