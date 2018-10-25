//
//  DailyTaskModel.swift
//  TimyShift
//
//  Created by USER on 2018/10/3.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation

class DailyTaskModel: NSObject, NSCoding, Codable {
    
    var taskList = Array<TaskModel>()
    
    init(task: TaskModel){
        taskList.append(task)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskList, forKey: "taskList")
    }
    
    required init?(coder aDecoder: NSCoder) {
        taskList = aDecoder.decodeObject(forKey: "taskList") as! Array
    }
}
