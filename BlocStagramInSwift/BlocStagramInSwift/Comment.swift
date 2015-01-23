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

    convenience init(commentDictionary: NSDictionary) {
        self.init()
        if let idNumberP = commentDictionary["id"] as? String {
            idNumber = idNumberP
        }
        text = commentDictionary["text"] as? String
        from = User(userDictionary: commentDictionary["from"] as NSDictionary)
    }

}
