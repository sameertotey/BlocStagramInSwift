//
//  DataSource.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Foundation
import KeychainAccess
import Alamofire


class DataSource: NSObject {
    
    dynamic var mediaItems = [Media]()
    
    
    var isRefreshing = false
    var isLoadingOlderItems = false
    var thereAreNoMoreOlderMessages = false
    
    var accessToken = ""

    
    // The sharedInstance class function will create and return the same instance of DataSource, directly calling the initializer will still create a new instance
    struct SharedInstanceStore {
        static var once: dispatch_once_t = 0
        static var instance: DataSource?
        static let instagramClientID = "f88ae7fd0c894b308cd15ccdcb7a19c5"
    }
    
    class func sharedInstance() -> DataSource {
        dispatch_once(&SharedInstanceStore.once) {
            SharedInstanceStore.instance = DataSource()
        }
        return SharedInstanceStore.instance!
    }
    
    override init() {
        super.init()
        // We can prevent more than one instances by using the following assert
//        assert(SharedInstanceStore.instance == nil, "Singleton already initialized!")
        registerForAccessTokenNotification()
    }
    
    func registerForAccessTokenNotification() {
        let keychain = Keychain(service: "com.sameertotey.BlocStagramInSwift")
        let accessToken = keychain["access token"]
        
        if accessToken == nil {
            NSNotificationCenter.defaultCenter().addObserverForName(ReceivedInstagramAccessToken, object: nil, queue: nil) { (note: NSNotification!) -> Void in
                self.accessToken = note.object as String
                keychain["access token"] = self.accessToken
                // Got the token populate the initial data
                self.populateData(parameters: nil) { error in
                    println("Completed initial population")
                    println("Completed images")
                }
            }
        } else {
            self.accessToken = accessToken!
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                let fullURL = self.urlForCache("mediaItems")
                if let mediaItemsData = NSData(contentsOfURL: fullURL) {
                    let storedMediaItems = NSKeyedUnarchiver.unarchiveObjectWithData(mediaItemsData) as NSArray

                    dispatch_async(dispatch_get_main_queue()) {
                        if storedMediaItems.count > 0 {
                            self.willChangeValueForKey("mediaItems")
                            self.mediaItems = storedMediaItems as [Media]
                            self.didChangeValueForKey("mediaItems")
                        } else {
                            self.populateData(parameters: nil) { error in
                                println("Completed initial population")
                                for mediaItem in self.mediaItems  {
                                    self.downloadImageFor(mediaItem: mediaItem)
                                }
                                println("Completed images")
                            }
                        }
                    }
                } else {
                    self.populateData(parameters: nil) { error in
                        println("Completed initial population")
                        for mediaItem in self.mediaItems  {
                            self.downloadImageFor(mediaItem: mediaItem)
                        }
                        println("Completed images")
                    }
                }
            }
        }
    }
    
     //MARK: - Key/Value Observing
    
    func countOfMediaItems() -> Int {
        return mediaItems.count;
    }
    
    func objectInMediaItemsAtIndex (index: Int) -> Media {
        return mediaItems[index] 
    }
    
    func insertObject(object: Media, inMediaItemsAtIndex index:Int) {
        mediaItems.insert(object, atIndex: index)
    }
    
    func removeObjectFromMediaItemsAtIndex(index: Int) {
        mediaItems.removeAtIndex(index)
    }
    
    func replaceObjectInMediaItemsAtIndex(index: Int, withObject object: Media) {
        mediaItems.removeAtIndex(index)
        mediaItems.insert(object, atIndex: index)
    }
    
    func deleteMediaItem(item: Media) {
        var mutableArrayWithKVO = mutableArrayValueForKey("mediaItems") as NSMutableArray
        mutableArrayWithKVO.removeObject(item)
        
    }
    
    func requestNewItemsWithCompletionHandler(completionHandler:(error: NSError?) -> ()) {
        thereAreNoMoreOlderMessages = false
        if !self.isRefreshing {
            self.isRefreshing = true;

            if let minID = mediaItems.first?.idNumber {
                var parameters = ["min_id": minID]
            
                populateData(parameters: parameters)  { error in
                    self.isRefreshing = false
                    completionHandler(error:nil)
                }
            }
        }
    }
    
    func requestOldItemsWithCompletionHandler(completionHandler:(error: NSError?) -> ()) {
        if !self.isLoadingOlderItems && !thereAreNoMoreOlderMessages {
            self.isLoadingOlderItems = true;
            
            if let maxID = mediaItems.last?.idNumber {
                var parameters = ["max_id": maxID]
                
                populateData(parameters: parameters)  { error in
                    self.isLoadingOlderItems = false
                    completionHandler(error:nil)
                }
            }
            
        }
    }

    func populateData(#parameters: NSDictionary?, completionHandler:(error: NSError?) -> ()) {
        if (accessToken != "") {
            // only try to get the data if there's an access token
    
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                // do the network request in the background, so the UI doesn't lock up
    
                var urlString = "https://api.instagram.com/v1/users/self/feed?access_token=\(self.accessToken)"
                
                if let myParameters = parameters {
                    for (key,  value) in myParameters {
                        // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                        urlString += "&\(key)=\(value)"
                    }
                }
    
                if let url = NSURL(string: urlString) {
                    let request = NSURLRequest(URL: url)
    
                    var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
                    var webError: NSError?
                    let responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse:response, error:&webError)
                    
                    if responseData != nil {
                        var jsonError: NSError?
                        let feedDictionary = NSJSONSerialization.JSONObjectWithData(responseData!, options:NSJSONReadingOptions(0), error:&jsonError) as? NSDictionary

                        if feedDictionary != nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                // done networking, go back on the main thread
                                self.parseDataFromFeedDictionary(feedDictionary!, fromRequestWithParameters:parameters)
                                completionHandler(error: nil)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                completionHandler(error:jsonError)
                                }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                        // done networking, go back on the main thread
                            completionHandler(error:webError)
                        }
                    }
                }
            }
        }
    }
    
    func parseDataFromFeedDictionary( feedDictionary: NSDictionary, fromRequestWithParameters parameters: NSDictionary?) {
//        NSLog("%@", feedDictionary);
        let mediaArray = feedDictionary["data"] as NSArray
        
        var tmpMediaItems = [Media]()
        for mediaDictionary in mediaArray  {
            let mediaItem = Media(mediaDictionary: mediaDictionary as NSDictionary)
            tmpMediaItems.append(mediaItem)
            // we cannot download the images here, they have to be done when the mediaItems have been updated
//            downloadImageFor(mediaItem: mediaItem)
        }
        
        var mutableArrayWithKVO = mutableArrayValueForKey("mediaItems")
        
        if let Uparameters = parameters {
            if Uparameters["min_id"] != nil {
                // This was a pull-to-refresh request
            
                let rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
                let indexSetOfNewObjects = NSIndexSet(indexesInRange:rangeOfIndexes)
            
                mutableArrayWithKVO.insertObjects(tmpMediaItems, atIndexes:indexSetOfNewObjects)
            } else if Uparameters["max_id"] != nil {
                // This was an infinite scroll request
                if tmpMediaItems.count == 0 {
                    // disable infinite scroll, since there are no more older messages
                    thereAreNoMoreOlderMessages = true
                }
                mutableArrayWithKVO.addObjectsFromArray(tmpMediaItems)
            }
        } else {
            willChangeValueForKey("mediaItems")
            self.mediaItems = tmpMediaItems;
            didChangeValueForKey("mediaItems")
        }
        for mediaItem in tmpMediaItems  {
            self.downloadImageFor(mediaItem: mediaItem)
        }

        if tmpMediaItems.count > 0 {
            // Write the changes to disk
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let numberOfItemsToSave = min(self.mediaItems.count, 50)
                let mediaItemsToSave = Array(self.mediaItems[0..<numberOfItemsToSave])
                
                let fullURL = self.urlForCache("mediaItems")
                let mediaItemData = NSKeyedArchiver.archivedDataWithRootObject(mediaItemsToSave)
                
                var dataError: NSError?
                let wroteSuccessfully = mediaItemData.writeToURL(fullURL, options: .AtomicWrite | .DataWritingFileProtectionCompleteUnlessOpen, error: &dataError)
                if (!wroteSuccessfully) {
                    NSLog("Couldn't write file: %@", dataError!)
                }
            }
            
        }
        
    }
    
    func downloadImageFor(#mediaItem: Media) {
        if (mediaItem.mediaURL != nil && mediaItem.image == nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let request = NSURLRequest(URL: mediaItem.mediaURL!)
                var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
                var webError: NSError?
    
                let imageData = NSURLConnection.sendSynchronousRequest(request, returningResponse:response, error:&webError)
    
                if (imageData != nil) {
                    if let image = UIImage(data: imageData!) {
                        mediaItem.image = image
                    }
        
                    dispatch_async(dispatch_get_main_queue()) {
                        let mutableArrayWithKVO = self.mutableArrayValueForKey("mediaItems")
                        let index = mutableArrayWithKVO.indexOfObject(mediaItem)
                        mutableArrayWithKVO.replaceObjectAtIndex(index, withObject:mediaItem)
                    }
                } else {
                    if let error = webError {
                        NSLog("Error downloading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func applicationCacheDirectory() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        
        return urls[urls.count-1] as NSURL
    }
    
    func urlForCache(location: String) -> NSURL {
        return applicationCacheDirectory().URLByAppendingPathExtension(location)
    }


}
