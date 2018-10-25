//
//  GroupManager.swift
//  TimyShift
//
//  Created by USER on 2018/9/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class GroupManager: NSObject, NSCoding {
    
    var inviteWorks = Dictionary<String, InviteWork>()
    var groups = Dictionary<String, GroupModel>()
    var currentGroup: GroupModel! {
        get { return groups[UserManager.um.currentGroupId] ?? nil }
    }
    var currentUser: MemberModel! {
        get { return currentGroup.members[UserManager.um.userId] ?? nil }
    }
    var colorList = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
    
    static let gm = GroupManager()
    
    private override init(){
        print("init GroupManager...")
    }
    
    deinit {
        print("deinit GroupManager...")
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(groups, forKey: "groups")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        groups = aDecoder.decodeObject(forKey: "groups") as! Dictionary
    }
    
    func getDailyTasks(keyDate: String) -> [TaskModel] {
        var dailyTasks = Array<TaskModel>()
        if UserManager.um.currentGroupId == UserManager.um.userId {
            for groupId in UserManager.um.groupIds {
                if let tasks = groups[groupId]?.dailyTasks[keyDate]?.taskList{
                    let selfTasks = tasks.filter { $0.ownerId == UserManager.um.userId }
                    dailyTasks.append(contentsOf: selfTasks)
                }
            }
        } else {
            dailyTasks = GroupManager.gm.currentGroup.dailyTasks[keyDate]?.taskList ?? dailyTasks
        }
        return dailyTasks.sorted(by: { $0.fromTime < $1.fromTime }) //按時間排序
    }
    
    func newMemberModel() -> MemberModel {
        let userId = UserManager.um.userId
        let userName = groups[userId]!.members[userId]!.memberName!
        let groupCount = groups.count
        let colorCount = colorList.count
        let newColor = colorList[groupCount % colorCount]
        return MemberModel(groupName: "Group\(groupCount)", memberName: userName, bgColor: newColor)
    }
    
    func addGroup(completion:@escaping (_ groupId: String)->()){
        let newGId = UserManager.um.newRandomId()
        groups[newGId] = GroupModel(owner: newMemberModel())
        UserManager.um.groupIds.append(newGId)
        UserManager.um.groupIndex = UserManager.um.groupIds.count - 1
        DataManager.dm.saveUserData()
        DataManager.dm.saveGroupData(groupId: newGId)
        completion(newGId)
    }
    
    func leaveGroup(groupId: String) {
        GroupManager.gm.groups[groupId]!.members[UserManager.um.userId] = nil
        let dailyTasks = GroupManager.gm.groups[groupId]!.dailyTasks
        for v in dailyTasks.values {
            v.taskList.removeAll { $0.ownerId == UserManager.um.userId }
        }
        if GroupManager.gm.groups[groupId]!.members.isEmpty {
            db.collection("groups").document(groupId).delete()
        } else {
            DataManager.dm.saveGroupData(groupId: groupId)
        }
        GroupManager.gm.groups[groupId] = nil
        
        UserManager.um.groupIds.removeAll { $0 == groupId }
        UserManager.um.groupIndex -= 1
        DataManager.dm.saveUserData()
    }
    
    func joinGroup(inviteCode: String, completion:@escaping (_ groupId: String, _ result: Bool)->()) {
        saveAccessTime(inviteCode: inviteCode) { result in
            if result {
                
                self.checkCodeValid(inviteCode: inviteCode) { groupId, result in
                    if result {
                        
                        self.saveMemberData(groupId: groupId) { result in
                            if result {
                                
                                self.loadGroupData(groupId: groupId) { result in
                                    if result {
                                        
                                        UserManager.um.groupIds.append(groupId)
                                        UserManager.um.groupIndex = UserManager.um.groupIds.count - 1
                                        DataManager.dm.saveUserData()
                                        
                                        print("join group succeed")
                                        completion(groupId, true)
                                        
                                    } else {
                                        print("join group does not exist")
                                        completion(groupId, false)
                                    }
                                }
                                
                            } else {
                                print("save member data error")
                                completion(groupId, false)
                            }
                        }
                        
                    } else{
                        print("inviteCode expired error")
                        completion(groupId, false)
                    }
                }
            } else{
                print("save access time error")
                completion("no groupId", false)
            }
        }
    }

    func saveAccessTime(inviteCode: String, completion:@escaping (_ result: Bool)->()) {
        db.collection("codes").document(inviteCode).updateData(["accessAt" : FieldValue.serverTimestamp()]) { err in
            if let err = err {
                print(err)
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func checkCodeValid(inviteCode: String, completion:@escaping (_ groupId: String, _ result: Bool)->()) {
        db.collection("codes").document(inviteCode).getDocument { document, err in
            if let document = document, document.exists {
                let groupId = document.get("groupId") as! String
                let createdAt = document.get("createdAt") as! Timestamp
                let acccessAt = document.get("accessAt") as! Timestamp
                
                if (acccessAt.seconds - createdAt.seconds) < 120 {
                    completion(groupId, true)
                }else{
                    let expired = Timestamp(seconds: acccessAt.seconds - 120 , nanoseconds: acccessAt.nanoseconds)
                    db.collection("codes").whereField("createdAt", isLessThan: expired ).getDocuments { querySnapshot, err in
                        for document in querySnapshot!.documents {
                            db.collection("codes").document(document.documentID).delete()
                        }
                    }
                    completion(groupId, false)
                }
            }
        }
    }
    
    func saveMemberData(groupId: String, completion:@escaping (_ result: Bool)->()) {
        if let data = try? JSONEncoder().encode(self.newMemberModel()) {
            if let modelDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                db.collection("groups").document(groupId).setData(["members": [UserManager.um.userId : modelDict]], merge: true ) { err in
                    if let err = err {
                        print(err)
                        completion(false)
                    }else{
                        completion(true)
                    }
                }
            }else{
                print("Member Data JSONSerialization error")
                completion(false)
            }
        }else{
            print("Member Data JSONEncoder error")
            completion(false)
        }
    }
    
    func loadGroupData(groupId: String, completion:@escaping (_ result: Bool)->()){
        db.collection("groups").document(groupId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    if let json = try? JSONSerialization.data(withJSONObject: data, options: []) {
                        if let model = try? JSONDecoder().decode(GroupModel.self, from: json) {
                            GroupManager.gm.groups[groupId] = model
                            print("Group Document successfully readed!")
                            completion(true)
                        }else{
                            print("JSONDecoder error")
                            completion(false)
                        }
                    }else{
                        print("JSONSerialization error")
                        completion(false)
                    }
                }else{
                    print("Group Document parse error")
                    completion(false)
                }
            }else{
                print("Group Document does not exist")
                completion(false)
            }
        }
    }
}
