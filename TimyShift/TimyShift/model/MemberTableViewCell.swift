//
//  MemberTableViewCell.swift
//  TimyShift
//
//  Created by USER on 2018/9/17.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memberNameLabel: UILabel!
    
    func initCell(member: MemberModel) {
        memberNameLabel.text = member.memberName
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
