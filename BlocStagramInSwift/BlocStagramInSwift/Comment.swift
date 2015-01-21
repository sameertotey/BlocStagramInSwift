//
//  Comment.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class Comment: NSObject {
    var idNumber: String
    var from: User?
    var text: String?
    
    override init() {
        idNumber = "";
        super.init()
    }

}
