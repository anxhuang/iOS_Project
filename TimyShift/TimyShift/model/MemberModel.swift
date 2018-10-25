//
//  MemberModel.swift
//  TimyShift
//
//  Created by USER on 2018/9/17.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class MemberModel: NSObject, NSCoding, Codable{
    
    private var bgColor: String!
    private var bgColorTemp: String!
    private var textColor: String = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).hexString
    private var textColorTemp: String!
    
    var groupName: String!
    var memberName: String!
    var tasks = Array<TaskModel>()
    
    private enum CodingKeys: String, CodingKey { //For skip ColorTemp
        case bgColor, textColor, groupName, memberName, tasks
    }
    
    init(groupName: String, memberName: String, bgColor: UIColor) {
        self.groupName = groupName
        self.memberName = memberName
        self.bgColor = bgColor.hexString
    }
    
    func setBgColor(_ bgColor: UIColor) {
        self.bgColor = bgColor.hexString
    }
    
    func getBgColor() -> UIColor {
        return UIColor(hexString: bgColor)
    }
    
    func setTextColor(_ textColor: UIColor) {
        self.textColor = textColor.hexString
    }
    
    func getTextColor() -> UIColor {
        return UIColor(hexString: textColor)
    }
    
    func setBgColorTemp(_ bgColorTemp: UIColor) {
        self.bgColorTemp = bgColorTemp.hexString
    }
    
    func getBgColorTemp() -> UIColor {
        return UIColor(hexString: bgColorTemp ?? bgColor)
    }
    
    func setTextColorTemp(_ textColorTemp: UIColor) {
        self.textColorTemp = textColorTemp.hexString
    }
    
    func getTextColorTemp() -> UIColor {
        return UIColor(hexString: textColorTemp ?? textColor)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(bgColor, forKey: "bgColor")
        aCoder.encode(textColor, forKey: "textColor")
        aCoder.encode(groupName, forKey: "groupName")
        aCoder.encode(memberName, forKey: "memberName")
        aCoder.encode(tasks, forKey: "tasks")
    }
    
    required init?(coder aDecoder: NSCoder) {
        bgColor = aDecoder.decodeObject(forKey: "bgColor") as? String
        textColor = aDecoder.decodeObject(forKey: "textColor") as! String
        groupName = aDecoder.decodeObject(forKey: "groupName") as? String
        memberName = aDecoder.decodeObject(forKey: "memberName") as? String
        tasks = aDecoder.decodeObject(forKey: "tasks") as! Array
    }
}
