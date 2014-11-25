//
//  ChapterViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/25/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class ChapterViewController : UITableViewController {
    var book: Book!
    var chosenChapter = 0
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book.numChapters!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChapterCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = "\(book.citeFull) \(indexPath.row + 1)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        chosenChapter = indexPath.row + 1
        performSegueWithIdentifier("Show Scripture", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Scripture" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                if let destVC = segue.destinationViewController as? ScriptureViewController {
                    destVC.book = book
                    
                    destVC.chapter = chosenChapter
                    
                    destVC.title = book.tocName
                }
            }
        }
    }
    
}
