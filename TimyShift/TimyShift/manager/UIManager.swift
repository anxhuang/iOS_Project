//
//  UIManager.swift
//  TimyShift
//
//  Created by USER on 2018/9/12.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class UIManager{
    
    static let ui = UIManager()
    
    private init(){
        print("init UIManager...")
    }
    
    deinit {
        print("deinit UIManager...")
    }
    
    func dismissKeyboardOnTapView(view: UIView) {
        //使touch到TableView可以讓鍵盤下降的作法(萬用解)
        let endEditingTapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        endEditingTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(endEditingTapGesture)
    }

    func addLocallNotification(date: Date, task: TaskModel) {
        
        let calendar = Calendar.autoupdatingCurrent
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: task.fromTime)
        let minute = calendar.component(.minute, from: task.fromTime)
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        let fireDate = calendar.date(from: dateComponents)
        
        let groupName = task.getGroupName()
        let (from, fm) = task.getFromTime()
        let (to, tm) = task.getToTime()
        let schedule = task.fullDay ? "Full Day" : "\(fm) \(from) - \(tm) \(to)"
        let id = task.taskId!
        
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        notification.alertBody = "Group:  \(groupName)\nScheduled:  \(schedule)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["identifier" : id]
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func cancelLocallNotification(task: TaskModel) {
        if let localNotifications = UIApplication.shared.scheduledLocalNotifications {
            for notification in localNotifications {
                if let identifier = notification.userInfo!["identifier"] as? String, identifier == task.taskId {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
    }
    
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer();
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x:0, y:self.frame.height - thickness, width:self.frame.width, height:thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x:0, y:0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x:self.frame.width - thickness, y: 0, width: thickness, height:self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}

extension UIColor {
    
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var hexString: String {
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}

extension Date {
    
    func hourtime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter.string(from: self)
    }
    
    func ampm() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return Int(dateFormatter.string(from: self))! < 12 ? dateFormatter.amSymbol : dateFormatter.pmSymbol
    }
    
    func toKey() -> String {
        return self.toString(format: "yyyyMMdd")
    }
    
    static func fromKey(key: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: key)
    }
    
    func toString(format: String, secondsFromGMT: Int? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let sec = secondsFromGMT {
            dateFormatter.timeZone = TimeZone(secondsFromGMT: sec)
        }
        return dateFormatter.string(from: self)
    }
    
    func fromString(format: String, secondsFromGMT: Int? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let sec = secondsFromGMT {
            dateFormatter.timeZone = TimeZone(secondsFromGMT: sec)
        }
        return dateFormatter.date(from: dateFormatter.string(from: self))
    }
}

extension UIViewController {
    
    func showAlertDialog(title: String, message: String) {
        let alertDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertDialog.addAction(yesAction)
        present(alertDialog, animated: true, completion: nil)
    }
}
