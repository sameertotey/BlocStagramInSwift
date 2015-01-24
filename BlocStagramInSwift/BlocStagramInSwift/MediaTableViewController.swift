//
//  ImagesTableViewController.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Foundation

// Global context for Key Value Observing
private var myContext = 0

let cellReuseIdentifier = "mediaCell"

class MediaTableViewController: UITableViewController {
    
    var mediaItems: [Media] {
        get {
            return DataSource.sharedInstance().mediaItems
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let cellNib = UINib(nibName: "MediaTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellReuseIdentifier)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refreshControlDidFire:", forControlEvents: .ValueChanged)
        
        DataSource.sharedInstance().addObserver(self, forKeyPath: "mediaItems", options: .New | .Old, context: &myContext)
        
    }

    deinit {
        DataSource.sharedInstance().removeObserver(self, forKeyPath: "mediaItems", context: &myContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlDidFire(sender: UIRefreshControl) {
        DataSource.sharedInstance().requestNewItemsWithCompletionHandler {error in
            sender.endRefreshing()
            }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            println("DataSource Changed: \(change[NSKeyValueChangeNewKey])")
            println("keypath = \(keyPath)")
            println("object = \(object)")
            println("Change = \(change)")
//            NSLog(@"Datasource ");
            if (object as DataSource == DataSource.sharedInstance()) && (keyPath == "mediaItems") {
                // We know mediaItems changed.  Let's see what kind of change it is.
                let kindOfChange = NSKeyValueChange(rawValue: change[NSKeyValueChangeKindKey] as UInt)
                
                if (kindOfChange! == .Setting) {
                    // Someone set a brand new images array
                    tableView.reloadData()
                }
//                } else if (kindOfChange! == .Insertion ||
//                    kindOfChange! == .Removal ||
//                    kindOfChange! == .Replacement) {
//                        // We have an incremental change inserted, deleted, or replaced images
//                        
//                        // Get a list of the index (or indices) that changed
//                        let indexSetOfChanges: NSIndexSet = change[NSKeyValueChangeIndexesKey]! as NSIndexSet
//                        
//                        // Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
//                        var indexPathsThatChanged = [NSIndexPath]()
//                        indexSetOfChanges.enumerateIndexesUsingBlock { (idx, _) -> Void in
//                            indexPathsThatChanged.append(NSIndexPath(forRow: idx, inSection: 0))
//                            }
//                        
//                        // Call `beginUpdates` to tell the table view we're about to make changes
//                        tableView.beginUpdates()
//                        
//                        // Tell the table view what the changes are
//                        switch kindOfChange! {
//                        case .Insertion:
//                            tableView.insertRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation: .Automatic)
//                        case .Removal:
//                            tableView.deleteRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation: .Automatic)
//                        case .Replacement:
//                            tableView.reloadRowsAtIndexPaths(indexPathsThatChanged, withRowAnimation: .Automatic)
//                        default:
//                            println("unexpected kind of change")
//                        }
//                        
//                        // Tell the table view that we're done telling it about changes, and to complete the animation
//                        tableView.endUpdates()
//                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    // MARK: - Table view data source


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return mediaItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as MediaTableViewCell

        // Configure the cell...
//        cell.mediaCellImageView.image = images[indexPath.row]
        cell.mediaItem = mediaItems[indexPath.row] as Media
        
        return cell
    }
    
    override func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            let item = mediaItems[indexPath.row] as Media
          return MediaTableViewCell.heightForMediaItem(item, width: CGRectGetWidth(self.view.bounds))
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let item = DataSource.sharedInstance().mediaItems[indexPath.row]
            DataSource.sharedInstance().deleteMediaItem(item)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = DataSource.sharedInstance().mediaItems[indexPath.row];
        if item.image != nil {
            return 350;
        } else {
            return 150;
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func infiniteScrollIfNecessary() {
        var visiblePaths = tableView.indexPathsForVisibleRows()
        
        if visiblePaths?.count > 0 {
            if let bottomIndexPath = visiblePaths?.removeLast() as? NSIndexPath {
    
                if (bottomIndexPath.row == DataSource.sharedInstance().mediaItems.count - 1) {
                    // The very last cell is on screen
                    DataSource.sharedInstance().requestOldItemsWithCompletionHandler{error in
                        println("infinite scroll")
                    }
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        infiniteScrollIfNecessary()
    }

}
