//
//  TaskTableViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/25.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class DailyTaskTableViewController: UITableViewController {
    
    var editDate: Date!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.title = "Task List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onClickAddTaskButton))
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddTaskSegue":
            let addTaskVC = segue.destination as! EditTaskViewController
            addTaskVC.editingTarget = "GroupTask"
            addTaskVC.editingDate = editDate
        case "EditTaskSegue":
            let editTaskVC = segue.destination as! EditTaskViewController
            editTaskVC.deleteButtonStatus = true
            editTaskVC.deleteButtonAlpha = 1
            editTaskVC.createButtonTitle = "SAVE"
            let index = sender as! IndexPath
            editTaskVC.editingTarget = "GroupTask"
            editTaskVC.editingDate = editDate
            editTaskVC.editingItemIndex = index.row
        default:
            break
        }
        
        
    }
    
    @objc func onClickAddTaskButton() {
        performSegue(withIdentifier: "AddTaskSegue", sender: self)
    }
    
    @IBAction func userBack(_ sender: UIStoryboardSegue){
        DataManager.data.saveData()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let rows = currentGroup.groupTasks[editDate]?.taskList.count ?? 0
        
        return rows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableCell", for: indexPath) as! DateTaskTableViewCell
        // Configure the cell...
        cell.initCell(task: currentGroup.groupTasks[editDate]!.taskList[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "EDIT") { (rowAction, indexPath) in
            self.performSegue(withIdentifier: "EditTaskSegue", sender: indexPath)
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            let alertDialog = UIAlertController(title: "Delete Task", message: "Are you sure?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                currentGroup.groupTasks[self.editDate]!.taskList.remove(at: indexPath.row)
                DataManager.data.saveData()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertDialog.addAction(cancelAction)
            alertDialog.addAction(yesAction)
            self.present(alertDialog, animated: true, completion: nil)
        }
        
        return[deleteAction, editAction]
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if currentGroup.groupTasks[editDate]!.taskList[indexPath.row].ownerId != DataManager.data.userId {
            return false
        }
        return true
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
