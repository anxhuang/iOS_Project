//
//  EditThemeViewController.swift
//  TimyShift
//
//  Created by USER on 2018/9/21.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class EditThemeViewController: UITableViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ampmLabel: UILabel!
    @IBOutlet weak var taskView: UIView!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var dailyLabelA: UILabel!
    @IBOutlet weak var dailyViewA: UIView!
    @IBOutlet weak var dailyLabelB: UILabel!
    @IBOutlet weak var dailyViewB: UIView!
    @IBOutlet weak var dailyLabelC: UILabel!
    @IBOutlet weak var dailyViewC: UIView!
    
    @IBOutlet weak var textSlider: UISlider!
    @IBOutlet weak var hueSlider: UISlider!
    @IBOutlet weak var satSlider: UISlider!
    @IBOutlet weak var brightSlider: UISlider!
    
    var sampleLabels: [UILabel]!
    var sampleViews: [UIView]!
    
    var initTextColor: UIColor!
    var initViewColor: UIColor!
    
    var textGray: CGFloat = 0
    var hue: CGFloat = 0
    var sat: CGFloat = 0
    var bright: CGFloat = 0
    var alpha: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Theme"
        
        sampleLabels = [timeLabel, ampmLabel, groupLabel, dailyLabelA, dailyLabelB, dailyLabelC]
        sampleViews = [taskView, groupView, dailyViewA, dailyViewB, dailyViewC]
        
        initTextColor = GroupManager.gm.currentUser.getTextColorTemp()
        initViewColor = GroupManager.gm.currentUser.getBgColorTemp()
        
        initPreviewSample()
        initSliders()
        
        sampleViews.forEach { $0.layer.cornerRadius = 2.5 }
        taskView.layer.cornerRadius = 4
        groupView.layer.cornerRadius = 4
    }
    
    func initPreviewSample() {
        timeLabel.text = Date().hourtime()
        ampmLabel.text = Date().ampm()
        dailyLabelA.text = Date().ampm() + Date().hourtime() 
        
        sampleLabels.forEach { $0.textColor = initTextColor }
        sampleViews.forEach { $0.backgroundColor = initViewColor }
    }
    
    func initSliders(){
        initTextColor.getWhite(&textGray, alpha: &alpha)
        textSlider.value = Float(textGray)
        initViewColor.getHue(&hue, saturation: &sat, brightness: &bright, alpha: &alpha)
        hueSlider.value = Float(hue)
        satSlider.value = Float(sat)
        brightSlider.value = Float(bright)
    }
    
    @IBAction func onSliderValueChange(_ sender: UISlider) {
        switch sender.tag {
        case textSlider.tag:
            textGray = CGFloat(sender.value)
            let color = UIColor(white: textGray, alpha: 1.0)
            sampleLabels.forEach { $0.textColor = color }
        case hueSlider.tag:
            hue = CGFloat(sender.value)
            let color = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: 1.0)
            sampleViews.forEach { $0.backgroundColor = color }
        case satSlider.tag:
            sat = CGFloat(sender.value)
            let color = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: 1.0)
            sampleViews.forEach { $0.backgroundColor = color }
        case brightSlider.tag:
            bright = CGFloat(sender.value)
            let color = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: 1.0)
            sampleViews.forEach { $0.backgroundColor = color }
        default:
            break
        }
    }
    
    @IBAction func onClickSaveButton(_ sender: Any) {
        GroupManager.gm.currentUser.setTextColorTemp(timeLabel.textColor)
        GroupManager.gm.currentUser.setBgColorTemp(taskView.backgroundColor!)
        performSegue(withIdentifier: "BackSegue", sender: self)
    }
    
    @IBAction func onClickResetButton(_ sender: Any) {
        initPreviewSample()
        initSliders()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        return 44
    }

}
