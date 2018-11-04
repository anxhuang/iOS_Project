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
            let alert = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
            let restartAction = UIAlertAction(title: "PLAY AGAIN", style: .destructive) { _ in
                self.refreshView()
            }
            alert.addAction(cancelAction)
            alert.addAction(restartAction)
            self.present(alert, animated: true, completion: nil)
            self.restartButton.isHidden = false
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

