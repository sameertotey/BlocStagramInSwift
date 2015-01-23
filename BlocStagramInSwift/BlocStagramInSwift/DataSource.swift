//
//  DataSource.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Foundation


class DataSource: NSObject {
    
    dynamic var mediaItems = [Media]()
    
    
    var isRefreshing = false
    var isLoadingOlderItems = false
    
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
        NSNotificationCenter.defaultCenter().addObserverForName(ReceivedInstagramAccessToken, object: nil, queue: nil) { (note: NSNotification!) -> Void in
            self.accessToken = note.object as String
            // Got the token populate the initial data
            self.populateData(parameters: nil)
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
        if !self.isRefreshing {
            self.isRefreshing = true;

            self.isRefreshing = false
                
            completionHandler(error:nil);
        }
    }
    
    func requestOldItemsWithCompletionHandler(completionHandler:(error: NSError?) -> ()) {
        if !self.isLoadingOlderItems {
            self.isLoadingOlderItems = true;
              
            self.isLoadingOlderItems = false
            
            completionHandler(error:nil);
        }
    }

    func populateData(#parameters: NSDictionary?) {
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
                    var webError: NSErrorPointer = nil
                    let responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse:response, error:webError)
    
                    var jsonError: NSErrorPointer = nil
                    let feedDictionary = NSJSONSerialization.JSONObjectWithData(responseData!, options:NSJSONReadingOptions(0), error:jsonError) as? NSDictionary
    
                    if  let receivedDictionary = feedDictionary {
                        dispatch_async(dispatch_get_main_queue()) {
                            // done networking, go back on the main thread
                            self.parseDataFromFeedDictionary(receivedDictionary, fromRequestWithParameters:parameters)
                            }
                    }
                }
            }
        }
    }
    
    func parseDataFromFeedDictionary( feedDictionary: NSDictionary, fromRequestWithParameters parameters: NSDictionary?) {
        NSLog("%@", feedDictionary);
    }
    
}
