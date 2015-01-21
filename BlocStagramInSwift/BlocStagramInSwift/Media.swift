//
//  Media.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class Media: NSObject {
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

}
