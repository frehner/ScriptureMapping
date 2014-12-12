//
//  ScriptureViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/22/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class ScriptureViewController : UIViewController, UIWebViewDelegate, SuggestionDisplayDelegate {
    
    // MARK: - Properties
    var book: Book!
    var chapter = 0
    var geoId:String = ""
    
    lazy var backgroundQueue = dispatch_queue_create("background thread", nil)
    
    weak var mapViewController: MapViewController?
    
    var placeName:String! = ""
    var offset:String! = ""
    
    // MARK: - Outlets
    @IBOutlet weak var webView: ScriptureWebView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let html = ScriptureRenderer.sharedRenderer.htmlForBookId(book.id, chapter: chapter)
        //load indicated book/chapter into view
        
        webView.loadHTMLString(html, baseURL: nil)
        
        webView.suggestionDelegate = self
        
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
            
            mapVC.geoPlaces = ScriptureRenderer.sharedRenderer.collectedGeocodedPlaces
            mapVC.singleGeoPlaceId = geoId.toInt()!
            
            //config map view to current context
            
            mapVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            mapVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    // MARK: - Web view delegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.absoluteString?.rangeOfString(ScriptureRenderer.sharedRenderer.BASE_URL) != nil {
            
//            NSLog("geocoded place \(request)")
            
            var url = indices(ScriptureRenderer.sharedRenderer.BASE_URL)
            geoId = request.URL.absoluteString!.substringFromIndex(url.endIndex)
            
            if let mapVC = mapViewController {
                //adjust map to show point at default zoom level. look at id at get it from DB (vid5)
//                NSLog("You have a map view controller")
                performSegueWithIdentifier("Show Map", sender: self)
            } else {
                
            }
            
            return false
        }
        
        return true
    }
    
    // MARK: - Suggestion Display Delegate
    func displaySuggestionDialog(placeName:String, _ offset:String) {
        self.placeName = placeName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        self.offset = offset
        performSegueWithIdentifier("ShowSuggestionDialog", sender: self)
    }
    
    // MARK: - Modal functions
    @IBAction func cancelSuggestion(segue:UIStoryboardSegue) {
        //in case it doesn't auto-dismiss.
        webView.userInteractionEnabled = false
        webView.userInteractionEnabled = true
        
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: nil )
        }
    }
    
    @IBAction func saveSuggestion(segue:UIStoryboardSegue) {
         //save model from presented view controller
        
        let formTVC = segue.sourceViewController as FormTableViewController
        
        //save to server
        dispatch_async(backgroundQueue) {
            var sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
            
            sessionConfig.allowsCellularAccess = true
            sessionConfig.timeoutIntervalForRequest = 15.0
            sessionConfig.timeoutIntervalForResource = 15.0
            sessionConfig.HTTPMaximumConnectionsPerHost = 2
            
            var session = NSURLSession(configuration: sessionConfig)
            
            var reqUrl = NSURL(string: "http://scriptures.byu.edu/mapscrip/suggestpm.php?placename=\(self.placeName)&offset=\(self.offset)&latitude=\(formTVC.latitude.text)&longitude=\(formTVC.longitude.text)&viewLatitude=\(formTVC.viewLatitude.text)&viewLongitude=\(formTVC.viewLongitude.text)&viewTilt=\(formTVC.viewTilt.text)&viewRoll=\(formTVC.viewRoll.text)&viewAltitude=\(formTVC.viewAltitude.text)&viewHeading=\(formTVC.viewHeading.text)&bookId=\(self.book.id)&chapter=\(self.chapter)")
            NSLog("here's the url: \(reqUrl!)")
            var request = NSURLRequest(URL: reqUrl!)
            
            var task = session.dataTaskWithRequest(request) {
                (data: NSData!, response:NSURLResponse!, error:NSError!) in
                
                var succeeded = false
                
                if error == nil {
                    var jsonError = NSError?()
                    let resultRecord:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &jsonError)
                    
                    if jsonError == nil && resultRecord is NSDictionary {
                        let resultDict = resultRecord as NSDictionary
                        let resultCode = resultDict["result"] as Int
                        
                        if resultCode == 0 {
                            succeeded = true
                        } else {
                            //failed on the web server
                            NSLog("failed on web server")
                        }
//                        NSLog("result code = \(resultCode)")
                    }
                } else {
                    //there was an error
                    NSLog("HTTP error")
                }
                
                if !succeeded {
                    //notify user something went wrong
                    let alertController = UIAlertController(title: "Error", message: "Sorry, unable to send message to server. Check internet connection and try again.", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default) {
                        (action) in
//                        NSLog("You clicked button \(action)")
                    }
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            task.resume()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil )
            }
        }
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
