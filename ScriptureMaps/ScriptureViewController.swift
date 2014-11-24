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
    
    weak var mapViewController: MapViewController?
    
    // MARK: - Outlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let html = ScriptureRenderer.sharedRenderer.htmlForBookId(book.id, chapter: chapter)
        //load indicated book/chapter into view
        
        webView.loadHTMLString(html, baseURL: nil)
        
        configureMapViewController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureMapViewController()
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Map" {
            let navVC = segue.destinationViewController as UINavigationController
            let mapVC = navVC.topViewController as MapViewController
            
            //config map view to current context
            
            mapVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            mapVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    // MARK: - Web view delegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.absoluteString?.rangeOfString(ScriptureRenderer.sharedRenderer.BASE_URL) != nil {
            
            NSLog("geocoded place \(request)")
            
            if let mapVC = mapViewController {
                //adjust map to show point at default zoom level. look at id at get it from DB (vid5)
                NSLog("You have a map view controller")
            } else {
                performSegueWithIdentifier("Show Map", sender: self)
            }
            
            return false
        }
        
        return true
    }
    
    // MARK: - Helper funcs
    func configureMapViewController() {
        mapViewController = nil
        if let splitVC = splitViewController {
            if let navVC = splitVC.viewControllers.last as? UINavigationController {
                mapViewController = navVC.topViewController as? MapViewController
            }
        }
    }
    
}
