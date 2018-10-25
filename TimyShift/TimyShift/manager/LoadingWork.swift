//
//  LoadingWork.swift
//  TimyShift
//
//  Created by USER on 2018/10/1.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class LoadingWork {
    
    var workItem: DispatchWorkItem!
    var view = UIApplication.shared.windows.first!
    
    func start() {
        workItem = DispatchWorkItem {
            let topViewRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            let topView = UIView(frame: topViewRect)
            topView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.8)
            
            let label = UILabel()
            label.text = "Loading"
            label.textColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
            label.textAlignment = NSTextAlignment(CTTextAlignment.center)
            label.frame = CGRect(x: topView.center.x - 50, y: topView.center.y - 10, width: 100, height: 20)
            
            topView.addSubview(label)
            self.view.addSubview(topView)
            
            DispatchQueue.global().async {
                while(true){
                    if self.workItem.isCancelled {
                        DispatchQueue.main.async {
                            topView.removeFromSuperview()
                        }
                        break
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: workItem)
    }
    
}
