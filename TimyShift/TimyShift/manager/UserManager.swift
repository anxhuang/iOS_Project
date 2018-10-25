//
//  UserManager.swift
//  TimyShift
//
//  Created by USER on 2018/9/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation
import Firebase

class UserManager: NSObject, NSCoding{
    
    var userId = Auth.auth().currentUser!.uid
    var groupIds = Array<String>()
    
    var groupIndex = 0
    var currentGroupId: String {
        get{ return groupIds[groupIndex] }
    }
    
    static let um = UserManager()
    
    private override init(){
        print("init DataManager...")
    }
    
    deinit {
        print("deinit DataManager...")
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(groupIds, forKey: "groupIds")
    }
    
    required init?(coder aDecoder: NSCoder) {
        userId = aDecoder.decodeObject(forKey: "userId") as! String
        groupIds = aDecoder.decodeObject(forKey: "groupIds") as! Array
    }
    
    func newRandomId(length: Int = 28) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
