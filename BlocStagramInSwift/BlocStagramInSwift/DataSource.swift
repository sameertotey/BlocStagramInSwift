//
//  DataSource.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class DataSource: NSObject {
    
    var mediaItems = [Media]()
    
    // The sharedInstance class function will create and return the same instance of DataSource, directly calling the initializer will still create a new instance
    struct SharedInstanceStore {
        static var once: dispatch_once_t = 0
        static var instance: DataSource?
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
        addRandomData()
    }
    
    func addRandomData() {
        for i in 0...9 {
            let image = UIImage(named: "\(i).jpg")
            if let newImage = image {
                let media = Media()
                media.image = newImage
                media.user = randomUser()
                media.caption = randomStringOfLength(10)
                let commentCount = arc4random_uniform(20)
                for i in 0..<commentCount {
                    let comment = randomComment()
                    media.comments.append(comment)
                }
                mediaItems.append(media)
            }
        }
    }
    
    func randomUser() -> User {
        let user = User()
        user.userName =  randomStringOfLength(arc4random_uniform(10))
        
        let firstName = randomStringOfLength(arc4random_uniform(7))
        let lastName = randomStringOfLength(arc4random_uniform(12))
        user.fullName = "\(firstName) \(lastName))"
        return user
    }
    
    func randomComment() -> Comment {
        let comment = Comment()
        comment.from = randomUser()
        let wordCount = arc4random_uniform(20) + 1
        
        for i in 0..<wordCount {
            let word = randomStringOfLength(12)
            if let currentText = comment.text {
                comment.text = currentText + " " + word
            } else {
                comment.text = word + " "
            }
        }
        return comment
    }
    
    func randomStringOfLength(num:UInt32) -> String {
        var string = ""
        let alphabets = ["a", "b", "c", "d", "e", "f", "g", "h","i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        
        for index in 0..<num {
            let r = Int(arc4random_uniform(UInt32(alphabets.count)))
            string = string + alphabets[r]
        }
        return string
    }
}
