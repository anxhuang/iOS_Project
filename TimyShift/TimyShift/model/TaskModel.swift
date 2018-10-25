//
//  TaskModel.swift
//  TimyShift
//
//  Created by USER on 2018/9/14.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation
import UIKit

class TaskModel: NSObject, NSCoding, Codable {

    var taskId: String!
    var groupId: String!
    var ownerId: String!
    var fullDay: Bool!
    var isNotify: Bool!
    var fromTime: Date!
    var toTime: Date!
    
    init(groupId: String, ownerId: String, fullDay: Bool = false, isNotify: Bool = false,fromTime: Date, toTime: Date){
        self.taskId = UserManager.um.newRandomId()
        self.groupId = groupId
        self.ownerId = ownerId
        self.fullDay = fullDay
        self.isNotify = isNotify
        self.fromTime = fromTime
        self.toTime = toTime
    }
    
    private func getOwner() -> MemberModel {
        return GroupManager.gm.groups[groupId]!.members[ownerId]!
    }
    
    func getGroupName() -> String {
        return getOwner().groupName
    }

    func getOwnerName() -> String {
        return getOwner().memberName
    }

    func getTextColor() -> UIColor {
        return getOwner().getTextColor()
    }

    func getBgColor() -> UIColor {
        return getOwner().getBgColor()
    }
    
    func getFromTime() -> (String, String) {
        let time = fullDay ? "Full" : fromTime.hourtime()
        let ampm = fullDay ? "DAY" : fromTime.ampm()
        return (time, ampm)
    }
    
    func getToTime() -> (String, String) {
        let time = toTime.hourtime()
        let ampm = toTime.ampm()
        return (time, ampm)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskId, forKey: "taskId")
        aCoder.encode(groupId, forKey: "groupId")
        aCoder.encode(ownerId, forKey: "ownerId")
        aCoder.encode(fullDay, forKey: "fullDay")
        aCoder.encode(isNotify, forKey: "isNotify")
        aCoder.encode(fromTime, forKey: "fromTime")
        aCoder.encode(toTime, forKey: "toTime")
    }

    required init?(coder aDecoder: NSCoder) {
        taskId = aDecoder.decodeObject(forKey: "taskId") as? String
        groupId = aDecoder.decodeObject(forKey: "groupId") as? String
        ownerId = aDecoder.decodeObject(forKey: "ownerId") as? String
        fullDay = aDecoder.decodeObject(forKey: "fullDay") as? Bool
        isNotify = aDecoder.decodeObject(forKey: "isNotify") as? Bool
        fromTime = aDecoder.decodeObject(forKey: "fromTime") as? Date
        toTime = aDecoder.decodeObject(forKey: "toTime") as? Date
    }
}
