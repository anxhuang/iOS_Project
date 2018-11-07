//
//  Animal.swift
//  Emojeweled
//
//  Created by USER on 2018/11/2.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

protocol AnimalDelegate {
    func onTapDetected(_ animal: Animal)
}

class Animal: UILabel {
    
    var delegate: AnimalDelegate?
    
    convenience init(x: CGFloat, y: CGFloat, unitX: CGFloat, unitY:CGFloat, icon: String, delegate: AnimalDelegate) {
        
        self.init()
        self.frame = CGRect(x: x, y: y, width: unitX, height: unitY)
        self.text = icon
        self.font = UIFont(descriptor: .init(), size: CGFloat(unitX))
        self.adjustsFontSizeToFitWidth = true
        self.delegate = delegate

        //加入Tap功能
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapDetected(_:)))
        self.addGestureRecognizer(tapRecognizer)
        self.isUserInteractionEnabled = true //UILabel default "false"
    }
    
    @objc func onTapDetected(_ sender: UITapGestureRecognizer) {
        delegate?.onTapDetected(self)
    }
}
