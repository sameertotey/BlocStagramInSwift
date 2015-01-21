//
//  User.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class User: NSObject {
    var idNumber: String
    var userName: String?
    var fullName: String?
    var profilePictureURL: NSURL?
    var profilePicture: UIImage?
    
    override init() {
        idNumber = "";
        super.init()
    }
    
}
