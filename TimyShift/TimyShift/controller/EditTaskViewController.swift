//
//  EditTaskViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/12.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class EditTaskViewController: UITableViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var fullDaySwitch: UISwitch!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var keyDate: String!
    var editDate: Date!
    var taskIndex: Int!
    var task: TaskModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if keyDate != nil {
            editDate = Date.fromKey(key: keyDate)
        }

        if task == nil {
            navigationItem.title = "Create Task"
            
            groupNameLabel.text = GroupManager.gm.currentUser.groupName
            ownerNameLabel.text = GroupManager.gm.currentUser.memberName
            deleteButton.isEnabled = false
            deleteButton.alpha = 0.25
            createButton.setTitle("CREATE", for: .normal)
        
        } else {
            navigationItem.title = "Edit Task"
            
            groupNameLabel.text = task.getGroupName()
            ownerNameLabel.text = task.getOwnerName()
            deleteButton.isEnabled = true
            deleteButton.alpha = 1
            createButton.setTitle("SAVE", for: .normal)
            
            if task.fullDay {
                fullDaySetter(status: true)
            }else{
                fromTimePicker.setDate(task.fromTime, animated: true)
                toTimePicker.setDate(task.toTime, animated: true)
            }
            
            notifySwitch.isOn = task.isNotify
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fullDaySetter(status: Bool){
        fullDaySwitch.isOn = status
        
        //fromTimePicker.isEnabled = !status //for iOS 10+
        fromTimePicker.isUserInteractionEnabled = !status //for iOS 9.3
        fromTimePicker.alpha = !status ? 1 : 0.4 //for iOS 9.3
        
        //toTimePicker.isEnabled = !status //for iOS 10+
        toTimePicker.isUserInteractionEnabled = !status //for iOS 9.3
        toTimePicker.alpha = !status ? 1 : 0.4 //for iOS 9.3
        
        if status {
            fromTimePicker.setDate(Date().fromString(format: "yyyy-MM-dd 00:00:00")!, animated: true)
            toTimePicker.setDate(Date().fromString(format: "yyyy-MM-dd 23:59:59")!, animated: true)
        }
    }
    
    @IBAction func onClickFullDaySwitch(_ sender: UISwitch) {
        fullDaySetter(status: sender.isOn)
    }
    
    @IBAction func onClickCreateButton(_ sender: UIButton) {
        
        let fromTime = fromTimePicker.date.fromString(format: "1900-01-01 H:m:s")!
        let toTime = toTimePicker.date.fromString(format: "1900-01-01 H:m:s")!
        
        let newTask = TaskModel(groupId: UserManager.um.currentGroupId, ownerId: UserManager.um.userId, fullDay: fullDaySwitch.isOn, isNotify: notifySwitch.isOn, fromTime: fromTime, toTime: toTime)
        
        if keyDate == nil { //tasks
            if task == nil {
                GroupManager.gm.currentUser.tasks.append(newTask)
            } else {
                GroupManager.gm.currentUser.tasks[taskIndex] = newTask
            }
        } else { //groupTask
            if task == nil {
                GroupManager.gm.currentGroup.addDailyTask(keyDate: keyDate, newTask: newTask)
            } else {
                UIManager.ui.cancelLocallNotification(task: task)
                GroupManager.gm.groups[task.groupId]!.revDailyTask(keyDate: keyDate, task: task, newTask: newTask)
            }
            if newTask.isNotify {
                UIManager.ui.addLocallNotification(date: editDate, task: newTask)
            }
        }
        DataManager.dm.saveGroupData(groupId: newTask.groupId)
    }
    
    @IBAction func onClickDeleteButton(_ sender: UIButton) {
        let alertDialog = UIAlertController(title: "Delete Task", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            if self.keyDate == nil {
                GroupManager.gm.currentUser.tasks.remove(at: self.taskIndex)
            } else {
                UIManager.ui.cancelLocallNotification(task: self.task)
                GroupManager.gm.groups[self.task.groupId]!.delDailyTask(keyDate: self.keyDate, task: self.task)
            }
            DataManager.dm.saveGroupData(groupId: self.task.groupId)
            self.performSegue(withIdentifier: "BackSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertDialog.addAction(cancelAction)
        alertDialog.addAction(yesAction)
        present(alertDialog, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 0 < indexPath.section, indexPath.section < 3 {
            return 88
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
}
