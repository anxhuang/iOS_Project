//
//  DailyTaskTableViewCell.swift
//  TimyShift
//
//  Created by USER on 2018/9/25.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class DailyTaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ownerButton: UIButton!
    @IBOutlet weak var notifyImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    func initCell(date: Date, task: TaskModel) {
        
        //ownerButton
        if UserManager.um.currentGroupId == UserManager.um.userId {
            initOwnerButton(title: task.getGroupName(), textColor: task.getTextColor(), bgColor: task.getBgColor())
        } else if task.ownerId == UserManager.um.userId {
            initOwnerButton(title: task.getOwnerName(), textColor: task.getTextColor(), bgColor: task.getBgColor())
        } else {
            initOwnerButton(title: task.getOwnerName(), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), bgColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }
        
        //notifyImageView
        notifyImageView.isHidden = !(task.isNotify && task.ownerId == UserManager.um.userId)
        
        //timeLabel
        let (from, fm) = task.getFromTime()
        let (to, tm) = task.getToTime()
        let title = task.fullDay ? "Full Day" : "\(fm) \(from) - \(tm) \(to)"
        timeLabel.text = title
    }
    
    private func initOwnerButton(title: String, textColor: UIColor, bgColor: UIColor) {
        ownerButton.setTitle(title, for: .normal)
        ownerButton.setTitleColor(textColor, for: .normal)
        ownerButton.backgroundColor = bgColor
        ownerButton.layer.cornerRadius = 4
        ownerButton.titleLabel!.adjustsFontSizeToFitWidth = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
