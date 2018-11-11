//
//  MainViewController.swift
//  Emojeweled
//
//  Created by USER on 2018/11/2.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    var box: UIView!
    
    lazy var viewModel: MainViewModel = {
        return MainViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        viewModel.renewScoreLabel = { scoreString in
            self.scoreLabel.text = scoreString
        }
        
        viewModel.popGameOver = { () in
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewID") as! AlertViewController
            alert.delegate = self
            self.restartButton.isHidden = false
            self.present(alert, animated: true, completion: nil)
        }
        
        refreshView()
    }
    
    func refreshView() {
        
        if let box = box {
            box.removeFromSuperview()
        }
        restartButton.isHidden = true
        box = viewModel.initAnimals()
        view.addSubview(box)
    }
    
    @IBAction func onTapRestartButton(_ sender: UIButton) {
        refreshView()
    }

}

extension MainViewController: AlertViewDelegate {
    func setFinalScore() -> String {
        return viewModel.scoreToIcons(score: viewModel.score)
    }
    
    func onTapRestart() {
        refreshView()
    }
    
    func onTapCancel() {
        //do nothing
    }
    
    
}

