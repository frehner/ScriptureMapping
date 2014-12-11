//
//  BooksViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/22/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class BooksViewController : UITableViewController {
    var books: [Book]!
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = books[indexPath.row].fullName
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if books[indexPath.row].numChapters > 1 {
            performSegueWithIdentifier("Show Chapter", sender: self)
        } else {
            performSegueWithIdentifier("Show Scripture", sender: self)
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Scripture" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                if let destVC = segue.destinationViewController as? ScriptureViewController {
                    destVC.book = books[indexPath.row]
                    
                    destVC.chapter = 1
                    
                    destVC.title = books[indexPath.row].tocName
                }
            }
        } else if segue.identifier == "Show Chapter" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                if let destVC = segue.destinationViewController as? ChapterViewController {
                    destVC.book = books[indexPath.row]
                    destVC.title = books[indexPath.row].tocName
                }
            }
        }
    }
}
