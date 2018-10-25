//
//  ViewController.swift
//  TimyShift
//
//  Created by USER on 2018/8/31.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField:UITextField!
    @IBOutlet weak var nextButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //按鈕修圓角
        nextButton.layer.cornerRadius = nextButton.layer.frame.width/2
        
        UIManager.ui.dismissKeyboardOnTapView(view: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textFiedDidEndExit(_ sender: UITextField) {
        //一定要實作一個方法去連接Did End On Exit ，鍵盤才會自動下降 (方法內可以不用寫內容)
    }
    
    @IBAction func onNameTextFieldChanged(_ sender: UITextField) {
        if (nameTextField.text?.isEmpty)! {
            nextButton.isEnabled = false
            nextButton.alpha = 0.25
        }else{
            nextButton.isEnabled = true
            nextButton.alpha = 0.75
        }
    }
    
    @IBAction func onClickNextButton(_ sender: UIButton) {
        if let inputName = nameTextField.text, !inputName.isEmpty {
            let userId = UserManager.um.userId
            let user = MemberModel(groupName: "overview", memberName: inputName, bgColor: GroupManager.gm.colorList[0])
            GroupManager.gm.groups[userId] = GroupModel(owner: user)
            UserManager.um.groupIds.append(userId)
            DataManager.dm.saveUserData()
            DataManager.dm.saveGroupData(groupId: userId)
        }
    }
}

