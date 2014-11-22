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
        let cell = tableView.dequeueReusableCellWithIdentifier("Book Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel.text = books[indexPath.row].fullName
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
}
