//
//  InviteWork.swift
//  TimyShift
//
//  Created by USER on 2018/9/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit
import FirebaseFirestore

class InviteWork {
    
    var code: String!
    var countDown: Int!
    var workItem: DispatchWorkItem!
    var view: EditGroupViewController!
    
    init(view: EditGroupViewController, code: String!, countDown: Int!) {
        self.view = view
        self.code = code
        self.countDown = countDown
        
        db.collection("codes").document(code).setData(["groupId" : UserManager.um.currentGroupId, "createdAt" : FieldValue.serverTimestamp()]) { err in
            if let err = err {
                print(err)
            }else{
                self.start()
            }
        }
    }
    
    func start() {
        workItem = DispatchWorkItem {
            if self.countDown > 0 {
                DispatchQueue.main.async { //用main包起來優先權比較高(顯示較快)
                    self.view.inviteCodeButton.setTitle(self.code, for: .normal)
                    self.view.inviteCodeButton.isEnabled = false
                }
                for cs in (0...self.countDown).reversed() {
                    if self.workItem.isCancelled {break}
                    sleep(1)
                    DispatchQueue.main.async {
                        self.countDown = cs
                        let m = cs / 60
                        let s = String(format: "%02d", cs % 60)
                        self.view.countDownLabel.text = "(\(m):\(s))"
                    }
                    //print(cs,"Thread count")
                }
            }
            if !self.workItem.isCancelled {
                DispatchQueue.main.async { //用main包起來優先權比較高(顯示較快)
                    self.view.inviteCodeButton.setTitle("Generate", for: .normal)
                    self.view.inviteCodeButton.isEnabled = true
                    self.view.countDownLabel.text = ""
                }
                db.collection("codes").document(self.code).delete()
                GroupManager.gm.inviteWorks[UserManager.um.currentGroupId] = nil
            }
            //print("Thread End")
        }
        DispatchQueue.global().async(execute: workItem)
    }
    
    func restart(view: EditGroupViewController){
        workItem.cancel()
        self.view = view
        DispatchQueue.global().async {
            sleep(1)
            self.start()
        }
    }
}
