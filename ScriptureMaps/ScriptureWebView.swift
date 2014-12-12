//
//  ScriptureWebView.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 12/3/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

protocol SuggestionDisplayDelegate {
    func displaySuggestionDialog(String, String)
}

class ScriptureWebView : UIWebView {
    var placeName:String!
    var offset:String!
    
    var suggestionDelegate: SuggestionDisplayDelegate!
    
    func suggestGeocoding(sender: AnyObject?){
        // NEEDSWORK: replace with code to exec segue
        placeName = stringByEvaluatingJavaScriptFromString("window.getSelection().toString()")!
        offset = stringByEvaluatingJavaScriptFromString("getSelectionOffset()")!
//        NSLog("here's the text: \(placeName) and the offset: \(offset)")
        suggestionDelegate.displaySuggestionDialog(placeName, offset)
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "suggestGeocoding:" {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}
