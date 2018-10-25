//
//  DailyTaskTableViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/25.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class DailyTaskTableViewController: UITableViewController {
    
    var editDate: Date!
    var keyDate: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = editDate.toString(format: "MMMM d")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onClickAddTaskButton))
        
        keyDate = editDate.toKey()
        
        DataManager.dm.listenGroupData(groupId: UserManager.um.currentGroupId) { _ in
            self.tableView.reloadData()
            print("listener reload data")
        }
    }
    
//    override func didMove(toParent parent: UIViewController?) { <== replaced by listener
//        if let navC = parent as? UINavigationController {
//            let mainVC = navC.viewControllers.first as! MainViewController
//            mainVC.calendarCollectionView.reloadData()
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditTaskViewController {
            vc.keyDate = keyDate
            vc.task = sender as? TaskModel
        }
    }
    
    @objc func onClickAddTaskButton() {
        performSegue(withIdentifier: "EditTaskSegue", sender: self)
    }
    
    @IBAction func userBack(_ sender: UIStoryboardSegue){
        tableView.reloadData() //因為在overview會看到其他group 所以不能只依靠listener更新currentGroup
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GroupManager.gm.getDailyTasks(keyDate: keyDate).count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableCell", for: indexPath) as! DailyTaskTableViewCell
        // Configure the cell...
        cell.initCell(date: editDate, task: GroupManager.gm.getDailyTasks(keyDate: keyDate)[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let task = GroupManager.gm.getDailyTasks(keyDate: keyDate)[indexPath.row]
        
        let editAction = UITableViewRowAction(style: .normal, title: "EDIT") { (rowAction, indexPath) in
            self.performSegue(withIdentifier: "EditTaskSegue", sender: task)
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            let alertDialog = UIAlertController(title: "Delete Task", message: "Are you sure?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                UIManager.ui.cancelLocallNotification(task: task)
                GroupManager.gm.groups[task.groupId]!.delDailyTask(keyDate: self.keyDate, task: task)
                DataManager.dm.saveGroupData(groupId: task.groupId)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertDialog.addAction(cancelAction)
            alertDialog.addAction(yesAction)
            self.present(alertDialog, animated: true, completion: nil)
        }
        
        return [deleteAction, editAction]
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return GroupManager.gm.getDailyTasks(keyDate: keyDate)[indexPath.row].ownerId == UserManager.um.userId
    }

}
