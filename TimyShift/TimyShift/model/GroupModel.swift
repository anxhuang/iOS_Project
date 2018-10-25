//
//  GroupModel.swift
//  TimyShift
//
//  Created by USER on 2018/9/14.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit
import FirebaseFirestore

class GroupModel: NSObject, NSCoding, Codable {
    
    var members = Dictionary<String, MemberModel>()
    var dailyTasks = Dictionary<String, DailyTaskModel>() //key為8碼日期
    
    init(owner: MemberModel){
        members[UserManager.um.userId] = owner
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(members, forKey: "members")
        aCoder.encode(dailyTasks, forKey: "dailyTasks")
    }
    
    required init?(coder aDecoder: NSCoder) {
        members = aDecoder.decodeObject(forKey: "members") as! Dictionary
        dailyTasks = aDecoder.decodeObject(forKey: "dailyTasks") as! Dictionary
    }
    
    func addDailyTask(keyDate: String, newTask: TaskModel) {
        if let _ = dailyTasks[keyDate] {
            dailyTasks[keyDate]?.taskList.append(newTask)
        } else {
            dailyTasks[keyDate] = DailyTaskModel(task: newTask)
        }
    }
    
    func revDailyTask(keyDate: String, task: TaskModel, newTask: TaskModel) {
        let idx = dailyTasks[keyDate]?.taskList.firstIndex { $0.taskId == task.taskId }
        newTask.groupId = task.groupId
        dailyTasks[keyDate]?.taskList[idx!] = newTask
    }
    
    func delDailyTask(keyDate: String, task: TaskModel) {
        let idx = dailyTasks[keyDate]?.taskList.firstIndex { $0.taskId == task.taskId }
        dailyTasks[keyDate]?.taskList.remove(at: idx!)
        if dailyTasks[keyDate]?.taskList.count == 0 {
            dailyTasks[keyDate] = nil
        }
    }
}
