//
//  MainViewController.swift
//  Emojeweled
//
//  Created by USER on 2018/11/2.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    var box: UIView!
    var hintCounter = 0
    var observation: NSKeyValueObservation!
    
    lazy var viewModel: MainViewModel = {
        return MainViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.renewScoreLabel = { scoreString in
            UIView.performWithoutAnimation {
                self.scoreButton.setTitle(scoreString, for: .normal)
                self.scoreButton.layoutIfNeeded()
            }
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
        box = viewModel.initAnimals()
        view.addSubview(box)
        view.bringSubviewToFront(scoreButton)
        restartButton.isHidden = true
        hintCounter = 0
    }
    
    func autoPlay() {
        if viewModel.hint.count > 2 {
            viewModel.onTapDetected(viewModel.hint[0])
        } else {
            observation.invalidate()
            scoreButton.isEnabled = true
            scoreButton.alpha = 1
        }
    }
    
    // Removed/Comment this func to disable the hint trigger
    @IBAction func onTapScoreButton(_ sender: UIButton) {
        hintCounter += 1
        if hintCounter == 7 {
            sender.isEnabled = false
            sender.alpha = 0.4
            observation = viewModel.observe(\.isRunning, options: .new) { (viewModel, change) in
                if !change.newValue! {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.autoPlay()
                    }
                }
            }
            autoPlay()
        } else {
            sender.isEnabled = false
            viewModel.onTapDetected(viewModel.hint[0])
            DispatchQueue.global().async {
                while(self.viewModel.isRunning){}
                DispatchQueue.main.async {
                    sender.isEnabled = true
                }
            }
        }
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

