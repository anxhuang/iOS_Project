//
//  AlertViewController.swift
//  Emojeweled
//
//  Created by USER on 2018/11/11.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

protocol AlertViewDelegate: class {
    func setFinalScore() -> String
    func onTapRestart()
    func onTapCancel()
}

class AlertViewController: UIViewController {
    
    @IBOutlet weak var finalScore: UILabel!
    
    weak var delegate: AlertViewDelegate!
    
    override func awakeFromNib() {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        finalScore.text = delegate.setFinalScore()
        finalScore.font = UIFont.systemFont(ofSize: self.view.bounds.width/12 )
        finalScore.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        delegate.onTapCancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapRestartButton(_ sender: Any) {
        delegate.onTapRestart()
        self.dismiss(animated: true, completion: nil)
    }

}
