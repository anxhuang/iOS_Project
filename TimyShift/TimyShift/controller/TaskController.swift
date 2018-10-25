//
//  TaskController.swift
//  TimyShift
//
//  Created by USER on 2018/9/24.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

protocol TaskControllerDelegate: class {
    func onClickDetected(_ taskView: TaskView)
    func onDropDetected(_ taskView: TaskView)
}

class TaskController {
    
    weak var delegate: TaskControllerDelegate?

    var superView: UIView!
    var leadingAnchor: NSLayoutXAxisAnchor!
    var topAnchor: NSLayoutYAxisAnchor!
    var numEachRow: Int!
    var xSpacing: CGFloat!
    var ySpacing: CGFloat!
    var taskWidth: CGFloat!
    var taskHeight: CGFloat!
    var views = Array<UIView>()
    
    init (superView: UIView, leadingAnchor: NSLayoutXAxisAnchor, topAnchor: NSLayoutYAxisAnchor, numEachRow: Int) {
        self.superView = superView
        self.leadingAnchor = leadingAnchor
        self.topAnchor = topAnchor
        self.numEachRow = numEachRow
        self.taskWidth = superView.bounds.size.width * 0.8 / CGFloat(numEachRow)
        self.taskHeight = self.taskWidth
        self.xSpacing = superView.bounds.size.width * 0.2 / CGFloat(numEachRow + 1)
        self.ySpacing = self.xSpacing
    }
    
    func reload(owner: MemberModel) {
        for v in views {
            v.removeFromSuperview()
        }
        views.removeAll()
        for i in 0..<owner.tasks.count {
            let view = TaskView.initView()
            view.setView(owner: owner, taskIndex: i)
            superView.addSubview(view)
            views.append(view)
            
            let xGap = CGFloat(i%numEachRow)*xSpacing+CGFloat(i%numEachRow)*taskWidth
            let yGap = CGFloat(i/numEachRow)*ySpacing+CGFloat(i/numEachRow)*taskHeight
            
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xSpacing + xGap).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: ySpacing + yGap).isActive = true
            view.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: taskWidth).isActive = true
            view.bottomAnchor.constraint(equalTo: view.topAnchor, constant: taskHeight).isActive = true
            view.delegate = delegate
        }
    }

}
