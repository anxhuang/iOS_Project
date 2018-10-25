//
//  CalendarCollectionViewCell.swift
//  TimyShift
//
//  Created by USER on 2018/9/4.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayTaskLabelA: UILabel!
    @IBOutlet weak var dayTaskLabelB: UILabel!
    @IBOutlet var dayLabel: UILabel!
    
    let calendar = Calendar.autoupdatingCurrent
    var pageMonth: Int!
    var pageWeekday: Int!
    var cellDate: Date!
    
    func initCell(pageDate:Date, for indexPath:IndexPath){
        
        //設定日期屬性
        pageMonth = calendar.component(.month, from: pageDate)
        pageWeekday = calendar.component(.weekday, from: pageDate) //Sun:1, Mon:2
        
        //設定cell內dayLabel
        let param = indexPath.item - pageWeekday + 1
        cellDate = calendar.date(byAdding: .day, value: param, to: pageDate)
        dayLabel.text = calendar.component(.day, from: cellDate).description
        
        if Date().fromString(format: "yyyy-MM-dd 00:00:00", secondsFromGMT: 0) == cellDate {
            dayLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            dayLabel.font = UIFont.systemFont(ofSize: dayLabel.font.pointSize, weight: .heavy)
        } else if calendar.component(.month, from: cellDate) != pageMonth {
            dayLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            dayLabel.font = UIFont.systemFont(ofSize: dayLabel.font.pointSize, weight: .regular) //因為cell是Reuse的
        } else {
            dayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            dayLabel.font = UIFont.systemFont(ofSize: dayLabel.font.pointSize, weight: .regular) //因為cell是Reuse的
        }

        //設定cell內workLabel
        let keyDate = cellDate.toKey()
        let labels = [dayTaskLabelA, dayTaskLabelB]
        labels.forEach { $0!.isHidden = true }  //因為cell是Reuse的
        let tasks = GroupManager.gm.getDailyTasks(keyDate: keyDate)
        for i in 0..<tasks.count {
            if i == 2 {
                labels.last!!.text = "⋯"
                //如果後面有Task是自己的 要標顏色
                for j in 2..<tasks.count{
                    if tasks[j].ownerId == UserManager.um.userId {
                        labels.last!?.backgroundColor = GroupManager.gm.groups[tasks[j].groupId]?.members[UserManager.um.userId]!.getBgColor()
                    }
                }
                break
            }
            setLabel(label: labels[i]!, task: tasks[i])
        }
        
        //設定cell邊框
        self.layer.addBorder(edge: .top, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), thickness: 0.5)
    }
    
    private func setLabel (label: UILabel, task: TaskModel) {
        if task.ownerId == UserManager.um.userId {
            let (from, fm) = task.getFromTime()
            label.text = task.fullDay ? "Full Day" : fm+from
            label.textColor = task.getTextColor()
            label.backgroundColor = task.getBgColor()
        } else {
            label.text = task.getOwnerName()
            label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            label.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        
        label.layer.cornerRadius = 2.5
        label.clipsToBounds = true
        label.isHidden = false
    }

}
