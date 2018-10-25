//
//  EditGroupViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/17.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class EditGroupViewController: UITableViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var themeColorButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var inviteCodeButton: UIButton!
    @IBOutlet weak var leaveGroupButton: UIButton!
    
    let identifier = String(describing: MemberTableViewCell.self)
    let NibName = String(describing: MemberTableViewCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Group"
        
        //static與dynamic table cell混用需另外註冊
        let nib = UINib(nibName: NibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
        
        //初始化Button
        groupNameTextField.text = GroupManager.gm.currentUser.groupName
        userNameTextField.text = GroupManager.gm.currentUser.memberName
        themeColorButton.setTitleColor(GroupManager.gm.currentUser.getTextColor(), for: .normal)
        themeColorButton.backgroundColor = GroupManager.gm.currentUser.getBgColor()
        
        //邀請碼按鈕設定
        if let inviteWork = GroupManager.gm.inviteWorks[UserManager.um.currentGroupId] {
            inviteWork.restart(view: self)
        }else{
            inviteCodeButton.setTitle("Generate", for: .normal)
        }
        
        //MemberTableView Listener
        DataManager.dm.listenGroupData(groupId: UserManager.um.currentGroupId) { _ in
            self.tableView.reloadData()
        }
        
        //外觀設定
        themeColorButton.layer.cornerRadius = 4
        
        UIManager.ui.dismissKeyboardOnTapView(view: view)
    }
    
    @IBAction func textFiedDidEndExit(_ sender: UITextField) {
        //一定要實作一個方法去連接Did End On Exit ，鍵盤才會自動下降 (方法內可以不用寫內容)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return GroupManager.gm.currentGroup.members.count
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MemberTableViewCell
            let member = Array(GroupManager.gm.currentGroup.members.values)[indexPath.row]
            cell.initCell(member: member)
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 1))
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 44
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    @IBAction func onClickInviteCodeButton(_ sender: UIButton) {
        let code = String(Int.random(in: 10000000...99999999))
        GroupManager.gm.inviteWorks[UserManager.um.currentGroupId] = InviteWork(view: self, code: code, countDown: 120)
    }
    
    @IBAction func onClickSaveButton(_ sender: UIButton) {
        GroupManager.gm.currentUser.groupName = groupNameTextField.text
        GroupManager.gm.currentUser.memberName = userNameTextField.text
        GroupManager.gm.currentUser.setTextColor(themeColorButton.titleColor(for: .normal)!)
        GroupManager.gm.currentUser.setBgColor(themeColorButton.backgroundColor!)
        DataManager.dm.saveGroupData(groupId: UserManager.um.currentGroupId)
    }
    
    @IBAction func onClickLeaveButton(_ sender: UIButton) {
        let alertDialog = UIAlertController(title: "Leave Group", message: "The relative data will be removed and nonrecoverable. Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Leave", style: .destructive) { _ in
            GroupManager.gm.leaveGroup(groupId: UserManager.um.currentGroupId)
            self.performSegue(withIdentifier: "BackMainSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertDialog.addAction(cancelAction)
        alertDialog.addAction(yesAction)
        present(alertDialog, animated: true, completion: nil)
    }
    
    @IBAction func userBack(_ sender: UIStoryboardSegue) {
        themeColorButton.setTitleColor(GroupManager.gm.currentUser.getTextColorTemp(), for: .normal)
        themeColorButton.backgroundColor = GroupManager.gm.currentUser.getBgColorTemp()
    }
    
}
