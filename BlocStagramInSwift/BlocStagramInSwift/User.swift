//
//  User.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import Foundation

class User: NSObject, NSCoding {
    var idNumber: String
    var userName: String?
    var fullName: String?
    var profilePictureURL: NSURL?
    var profilePicture: UIImage?
    
    override init() {
        idNumber = "";
        super.init()
    }
    
    convenience init(userDictionary: NSDictionary) {
        self.init()
        if let idNumberP = userDictionary["id"] as? String {
            idNumber = idNumberP
        }
        userName = userDictionary["username"] as? String
        fullName = userDictionary["full_name"] as? String
        
        let profileURLString = userDictionary["profile_picture"] as? String
        
        if let profileURL = NSURL(string: profileURLString!) {
            self.profilePictureURL = profileURL;
        }

    }
    
    required init(coder aDecoder: NSCoder) {
        idNumber = aDecoder.decodeObjectForKey("idNumber") as String
        userName = aDecoder.decodeObjectForKey("userName") as String?
        fullName = aDecoder.decodeObjectForKey("fullName") as String?
        profilePictureURL = aDecoder.decodeObjectForKey("profilePictureURL") as NSURL?
        profilePicture = aDecoder.decodeObjectForKey("profilePicture") as UIImage?
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(idNumber, forKey:"idNumber")
        aCoder.encodeObject(userName, forKey:"userName")
        aCoder.encodeObject(fullName, forKey:"fullName")
        aCoder.encodeObject(profilePictureURL, forKey:"profilePictureURL")
        aCoder.encodeObject(profilePicture, forKey:"profilePicture")
    }
}
