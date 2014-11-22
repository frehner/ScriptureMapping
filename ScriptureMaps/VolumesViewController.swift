//
//  VolumesViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/22/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class VolumesViewController: UITableViewController {

    weak var detailViewController: MapViewController? = nil
    lazy var volumes = GeoDatabase.sharedGeoDatabase.volumes()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            detailViewController = split.viewControllers.last?.topViewController as? MapViewController
        }
        
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Books" {
            if let destVC = segue.destinationViewController as? BooksViewController {
                if let indexPath = tableView.indexPathForSelectedRow() {
                    destVC.books = GeoDatabase.sharedGeoDatabase.booksForParentId(indexPath.row + 1)
                    destVC.title = volumes[indexPath.row]
                }
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volumes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VolumeCell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.text = volumes[indexPath.row]
        return cell
    }

}

