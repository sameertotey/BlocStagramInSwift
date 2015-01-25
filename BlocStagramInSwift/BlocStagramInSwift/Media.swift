//
//  Media.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Foundation

class Media: NSObject, NSCoding {
    var idNumber: String
    var user: User?
    var mediaURL :NSURL?
    var image: UIImage?
    var caption: String?
    var comments = [Comment]()
   
    override init() {
        idNumber = "";
        super.init()
    }

    convenience init(mediaDictionary: NSDictionary) {
        self.init()
        if let idNumberP = mediaDictionary["id"] as? String {
            idNumber = idNumberP
        }
        user = User(userDictionary: mediaDictionary["user"] as NSDictionary)
        let standardResolutionImageURLString = ((mediaDictionary["images"]as NSDictionary)["standard_resolution"] as NSDictionary)["url"] as String!
        if let standardResolutionImageURL = NSURL(string: standardResolutionImageURLString) {
            mediaURL = standardResolutionImageURL
        }
        if let captionDictionary = mediaDictionary["caption"] as? NSDictionary {
            caption = captionDictionary["text"] as String?
        }
        for commentDictionary in ((mediaDictionary["comments"] as NSDictionary)["data"] as NSArray) {
            let comment = Comment(commentDictionary: commentDictionary as NSDictionary)
            comments.append(comment)
        }
    }

    required init(coder aDecoder: NSCoder) {
        idNumber = aDecoder.decodeObjectForKey("idNumber") as String
        user = aDecoder.decodeObjectForKey("user") as User?
        mediaURL = aDecoder.decodeObjectForKey("mediaURL") as NSURL?
        image = aDecoder.decodeObjectForKey("image") as UIImage?
        caption = aDecoder.decodeObjectForKey("caption") as String?
        comments = aDecoder.decodeObjectForKey("comments") as [Comment]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(idNumber, forKey:"idNumber")
        aCoder.encodeObject(user, forKey:"user")
        aCoder.encodeObject(mediaURL, forKey:"mediaURL")
        aCoder.encodeObject(image, forKey:"image")
        aCoder.encodeObject(caption, forKey:"caption")
        aCoder.encodeObject(comments, forKey:"comments")
    }

}
