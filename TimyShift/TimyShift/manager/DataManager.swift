//
//  DataManager.swift
//  TimyShift
//
//  Created by USER on 2018/9/7.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class DataManager {
    
    static let dm = DataManager()

    private init(){
        print("init DataManager...")
    }

    deinit {
        print("deinit DataManager...")
    }
    
    let url = NSHomeDirectory() + "/Documents/"
    
    func saveLocalData() {
        if NSKeyedArchiver.archiveRootObject(UserManager.um, toFile: url+"user.data") == true {
            print("user.data writing succeed")
        }else{
            print("user.data writing failed")
        }
    }
    
    func loadLocalData() -> Bool{
        //讀取客端資料
        if let unarchived = NSKeyedUnarchiver.unarchiveObject(withFile: url+"user.data") as? UserManager {
            UserManager.um.userId = unarchived.userId
            UserManager.um.groupIds = unarchived.groupIds
            print("user.data loading succeed")
            return true
        }else{
            print("user.data loading failed")
            return false
        }
    }
    
    //儲存遠端資料
    func saveUserData() {
        saveLocalData()
        let groupIdDict = ["groupIds":UserManager.um.groupIds]
        db.collection("users").document(UserManager.um.userId).setData(groupIdDict) { err in
            if let err = err {
                print("User Document writting error: \(err)")
            } else {
                print("User Document successfully written!")
            }
        }
    }

    func saveGroupData(groupId: String) {
        let data = try! JSONEncoder().encode(GroupManager.gm.groups[groupId])
        let modelDict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        db.collection("groups").document(groupId).setData(modelDict) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
    }
    
    //讀取遠端資料
//    func loadUserData(completion:@escaping (_ result: Bool)->()) {
//        db.collection("users").document(UserManager.um.userId).getDocument { (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()!
//                UserManager.um.groupIds = data["groupIds"] as! [String]
//                print("User Document successfully readed!")
//                completion(true)
//            } else {
//                print("User Document does not exist")
//            }
//        }
//    }

    
    func listenUserData(completion:@escaping (_ result: Bool)->()) {
        db.collection("users").document(UserManager.um.userId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion(false)
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                completion(false)
                return
            }
            
            //            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            //            print("\(source) data: \(document.data() ?? [:])")
            
            UserManager.um.groupIds = data["groupIds"] as! [String]
            print("User Document successfully readed!")
            completion(true)
        }
    }
    
    func listenGroupData(groupId: String, completion:@escaping (_ result: Bool)->()){
        db.collection("groups").document(groupId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion(false)
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                completion(false)
                return
            }
            
            //            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            //            print("\(source) data: \(document.data() ?? [:])")
            
            let json = try! JSONSerialization.data(withJSONObject: data, options: [])
            let model = try! JSONDecoder().decode(GroupModel.self, from: json)
            GroupManager.gm.groups[groupId] = model
            print("Group Document successfully readed!")
            completion(true)
        }
    }
}
