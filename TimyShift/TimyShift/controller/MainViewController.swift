//
//  CalendarViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/1.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var prevGroupButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var nextGroupButton: UIButton!
    @IBOutlet weak var addGroupButton: UIButton!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    let calendar = Calendar.autoupdatingCurrent
    var titleButton: UIButton!
    var alertDialog: UIAlertController!
    var taskController: TaskController!
    var currentDate: Date!
    var pageDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserManager.um.userId == "LocalUserId" {
            //第一次以匿名登入
            Auth.auth().signInAnonymously() { (authResult, error) in
                if error == nil {
                    //更新用戶端資料和更新伺服端資料
                    let localUserId = UserManager.um.userId
                    UserManager.um.userId = authResult!.user.uid
                    //更新用戶MemberModel
                    GroupManager.gm.groups[localUserId]!.members[authResult!.user.uid] = GroupManager.gm.groups[localUserId]!.members[localUserId]
                    GroupManager.gm.groups[localUserId]!.members[localUserId] = nil
                    //更新用戶GroupModel
                    GroupManager.gm.groups[authResult!.user.uid] = GroupManager.gm.groups[localUserId]
                    GroupManager.gm.groups[localUserId] = nil
                    //更新GroupIds陣列
                    UserManager.um.groupIds[0] = authResult!.user.uid
                    
                    DataManager.dm.saveGroupData(groupId: authResult!.user.uid)
                }else{
                    print(error!.localizedDescription)
                }
            }
            
        }
        
        //改造navigationBarTitle
        titleButton = UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        titleButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleButton.addTarget(self, action: #selector(onClickNavTitle), for: .touchUpInside)
        navigationItem.titleView = titleButton
        
        //外觀設定
        addTaskButton.layer.cornerRadius = 4
        groupButton.layer.cornerRadius = 4
        addGroupButton.layer.cornerRadius = 4
        
        //首次進入頁面初始化
        initDate()
        initCollections()
    
        //===========================Listener===============================
        let loading = LoadingWork()
        DataManager.dm.listenUserData() { _ in
            for groupId in UserManager.um.groupIds {
                DataManager.dm.listenGroupData(groupId: groupId) { _ in
                    loading.workItem.cancel()
                    self.refreshView()
                }
            }
        }
        loading.start()
        //===========================Listener===============================
        
    }
    
    func initDate(){
        
        //初始化currentDate (每次換view要重新抓取 避免跨日錯誤)
        currentDate = Date()
        //初始化pageDate
        pageDate = pageDate ?? currentDate.fromString(format: "yyyy-MM-01 00:00:00", secondsFromGMT: 0)
    }
    
    func initCollections() {
        
        //初始化CollectionView
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        taskController = TaskController(superView: view, leadingAnchor: view.leadingAnchor, topAnchor: addTaskButton.bottomAnchor, numEachRow: 5)
        taskController.delegate = self
    }
    
    func refreshView() {
        
        initDate()
    
        //將年月設定為BarTitle
        titleButton.setTitle(pageDate.toString(format: "MMMM yyyy"), for: .normal)
        navigationItem.titleView = titleButton

        //初始化groupButton
        groupButton.setTitle(GroupManager.gm.currentUser.groupName, for: .normal)
        groupButton.setTitleColor(GroupManager.gm.currentUser.getTextColor(), for: .normal)
        groupButton.backgroundColor = GroupManager.gm.currentUser.getBgColor()
        
        //初始化prev/nextGroupButton
        prevGroupButton.isEnabled = UserManager.um.groupIndex > 0
        nextGroupButton.isEnabled = UserManager.um.groupIndex < UserManager.um.groupIds.count - 1
        
        //讀取task
        taskController.reload(owner: GroupManager.gm.currentUser)
        calendarCollectionView.reloadData()
        print("Finished: refreshView()")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "DailyTaskSegue":
            let dateTaskVC = segue.destination as! DailyTaskTableViewController
            let editCell = sender as! CalendarCollectionViewCell
            dateTaskVC.editDate = editCell.cellDate
        case "EditTaskSegue":
            let editTaskVC = segue.destination as! EditTaskViewController
            let editTask = sender as! TaskView
            editTaskVC.taskIndex = editTask.taskIndex
            editTaskVC.task = GroupManager.gm.currentUser.tasks[editTaskVC.taskIndex]
        default:
            break
        }
        print("Finished: prepare()")
    }
    
    @objc func onClickNavTitle() {
        pageDate = nil
        print("Finished: onClickNavTitle()")
        refreshView()
    }
    
    //設定BarButton按下後改變月份並重讀View
    @IBAction func onClickBarButton(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            pageDate = calendar.date(byAdding: .month, value: -1, to: pageDate)
        case 1:
            pageDate = calendar.date(byAdding: .month, value: 1, to: pageDate)
        default:
            break
        }
        print("Finished: onClickBarButton()")
        refreshView()
    }
    
    @IBAction func onSwipeCalendar(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .right:
                pageDate = calendar.date(byAdding: .month, value: -1, to: pageDate)
            case .left:
                pageDate = calendar.date(byAdding: .month, value: 1, to: pageDate)
            default:
                break
            }
        }
        refreshView()
        print("Finished: onSwipeCalendar()")
    }

    @IBAction func onClickNavGroupButton(_ sender: UIButton) {
        switch sender.description {
        case prevGroupButton.description:
            UserManager.um.groupIndex -= 1
        case nextGroupButton.description:
            UserManager.um.groupIndex += 1
        default:
            break
        }
        print("Finished: onClickNavGroupButton()")
        refreshView()
    }
    
    
    @IBAction func onClickGroupButton(_ sender: UIButton) {
        if UserManager.um.groupIndex == 0 {
            performSegue(withIdentifier: "SettingSegue", sender: self)
        }else{
            performSegue(withIdentifier: "EditGroupSegue", sender: self)
        }
        print("Finished: onClickGroupButton()")
    }
    
    @IBAction func onClickAddGroupButton(_ sender: UIButton) {
        alertDialog = UIAlertController(title: "Create Group", message: "Type Invite Code to join a group", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let yesAction = UIAlertAction(title: "Create", style: .default) { _ in
            if let code = self.alertDialog.textFields?.first!.text, !code.isEmpty {
                GroupManager.gm.joinGroup(inviteCode: code) { groupId, result in
                    if result {
                        DataManager.dm.listenGroupData(groupId: groupId) { _ in
                            self.refreshView()
                        }
                        print("Finished: joinGroup()")
                        //self.refreshView() <== replaced by listener
                    } else {
                        self.showAlertDialog(title: "⚠️", message: "\nCode Expired\n")
                    }
                }
            }else{
                GroupManager.gm.addGroup { newGId in
                    DataManager.dm.listenGroupData(groupId: newGId) { _ in
                        self.refreshView()
                    }
                }
                print("Finished: addGroup()")
                //self.refreshView() <== replaced by listener
            }
        }
        
        alertDialog.addTextField { textField in
            textField.placeholder = "Leave empty to create new group"
            textField.addTarget(self, action: #selector(self.onTextChanged(_:)), for: .editingChanged)
        }
        
        alertDialog.addAction(cancelAction)
        alertDialog.addAction(yesAction)
        present(alertDialog, animated: true, completion: nil)
        print("Finished: onClickAddGroupButton()")
    }
    
    @objc func onTextChanged (_ sender: UITextField) { //若textField有輸入字就對yesAction換title
        let title = sender.text!.isEmpty ? "Create" : "Join"
        alertDialog.title = title + " Group"
        alertDialog.actions[1].setValue(title, forKey: "title")
    }
    
    //提供給其他頁面back用的
    @IBAction func userBack(_ sender: UIStoryboardSegue){
        print("Finished: userBack()")
        //refreshView() <== replaced by listener
    }
}

extension MainViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int{
        return 42
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //指定cell為CalendarCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCollectionViewCell
        cell.initCell(pageDate: pageDate, for: indexPath)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        //根據螢幕寬度設定cell尺寸
        return CGSize(width: self.view.bounds.size.width/7, height: self.view.bounds.size.width/7)
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        performSegue(withIdentifier: "DailyTaskSegue", sender: cell)
    }
}

extension MainViewController: TaskControllerDelegate {
    func onClickDetected(_ taskView: TaskView) {
        performSegue(withIdentifier: "EditTaskSegue", sender: taskView)
    }

    func onDropDetected(_ taskView: TaskView) {
        let cells = calendarCollectionView.visibleCells as! [CalendarCollectionViewCell]
        let taskCenterInCalendar = CGPoint(x: taskView.center.x, y: taskView.center.y - calendarCollectionView.frame.origin.y)
        for cell in cells {
            if cell.frame.contains(taskCenterInCalendar){
                let keyDate = cell.cellDate.toKey()
                let newTask = GroupManager.gm.currentUser.tasks[taskView.taskIndex]
                GroupManager.gm.currentGroup.addDailyTask(keyDate: keyDate, newTask: newTask)
                DataManager.dm.saveGroupData(groupId: newTask.groupId)
                //refreshView() <== replaced by listener
            }
        }
    }
}
