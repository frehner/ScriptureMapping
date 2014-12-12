//
//  ScriptureWebView.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 12/3/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

protocol SuggestionDisplayDelegate {
    func displaySuggestionDialog()
}

class ScriptureWebView : UIWebView {
    var suggestionDelegate: SuggestionDisplayDelegate!
    
    func suggestGeocoding(sender: AnyObject?){
        // NEEDSWORK: replace with code to exec segue
        suggestionDelegate.displaySuggestionDialog()
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "suggestGeocoding:" {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}
