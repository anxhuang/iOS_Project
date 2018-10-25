//
//  SettingViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/20.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var themeColorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.title = "Setting"
        
        groupNameTextField.text = GroupManager.gm.currentUser.groupName
        userNameTextField.text = GroupManager.gm.currentUser.memberName
        themeColorButton.setTitleColor(GroupManager.gm.currentUser.getTextColor(), for: .normal)
        themeColorButton.backgroundColor = GroupManager.gm.currentUser.getBgColor()
        
        themeColorButton.layer.cornerRadius = 4
        
        UIManager.ui.dismissKeyboardOnTapView(view: view)
    }

    @IBAction func textFiedDidEndExit(_ sender: UITextField) {
        //一定要實作一個方法去連接Did End On Exit ，鍵盤才會自動下降 (方法內可以不用寫內容)
    }
    
    @IBAction func userBack(_ sender: UIStoryboardSegue) {
        themeColorButton.setTitleColor(GroupManager.gm.currentUser.getTextColorTemp(), for: .normal)
        themeColorButton.backgroundColor = GroupManager.gm.currentUser.getBgColorTemp()
    }
    
    @IBAction func onClickSaveButton(_ sender: UIButton) {
        GroupManager.gm.currentUser.groupName = groupNameTextField.text
        GroupManager.gm.currentUser.memberName = userNameTextField.text
        GroupManager.gm.currentUser.setTextColor(themeColorButton.titleColor(for: .normal)!)
        GroupManager.gm.currentUser.setBgColor(themeColorButton.backgroundColor!)
        DataManager.dm.saveGroupData(groupId: UserManager.um.currentGroupId)
    }

}
