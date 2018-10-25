//
//  TaskView.swift
//  TimyShift
//
//  Created by USER on 2018/9/24.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class TaskView: UIView {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ampmLabel: UILabel!
    
    var taskIndex: Int!
    var lastLocation = CGPoint(x: 0, y: 0)
    var delegate: TaskControllerDelegate?
    
    class func initView() -> TaskView {
        let myClassNib = UINib(nibName: "TaskView", bundle: nil)
        let view = myClassNib.instantiate(withOwner: nil, options: nil)[0] as! TaskView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func setView(owner: MemberModel, taskIndex: Int) {
        self.taskIndex = taskIndex
        let task = owner.tasks[taskIndex]
        (timeLabel.text!, ampmLabel.text!) = task.getFromTime()
        timeLabel.textColor = owner.getTextColor()
        ampmLabel.textColor = owner.getTextColor()
        self.backgroundColor = owner.getBgColor()
        self.layer.cornerRadius = 6
        
        //實作Task拖曳功能
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanDetected(_:)))
        self.gestureRecognizers = [panRecognizer]
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickView(_:)))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onPanDetected(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            //可以覆蓋其他task
            self.superview?.bringSubviewToFront(self)
            self.alpha = 0.6
            lastLocation = self.center
        case .changed:
            self.center = sender.location(in: self.superview)
        case .ended:
            delegate?.onDropDetected(self)
            self.alpha = 1
            self.center = lastLocation
        default:
            break
        }
    }
    
    @objc func onClickView( _ sender: UITapGestureRecognizer) {
        delegate?.onClickDetected(self)
    }
    
}
