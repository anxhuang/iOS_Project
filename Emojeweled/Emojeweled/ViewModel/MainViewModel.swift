//
//  MainViewModel.swift
//  Emojeweled
//
//  Created by USER on 2018/11/2.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class MainViewModel {
    
    var unitX: CGFloat!
    var unitY: CGFloat!
    var box: UIView!
    var anime: UIDynamicAnimator!
    var guideX = Set<CGFloat>()
    var guideY = Set<CGFloat>()
    var lineUps = [Animal]()
    let animalIcons = ["🐶","🐹","🐻","🐯","🐮"]
    let scoreIcons = ["0️⃣","1️⃣","2️⃣","3️⃣","4️⃣","5️⃣","6️⃣","7️⃣","8️⃣","9️⃣"]
    
    //animals
    var animals = [Animal]()
    var tappedAnimals = [Animal]() {
        willSet {
            twinkleAnimals(stop: true)
        }
        didSet {
            twinkleAnimals()
        }
    }
    
    //score
    var score = 0 {
        didSet {
            let scoreString = scoreToIcons(score: score)
            renewScoreLabel?(scoreString)
        }
    }
    var renewScoreLabel: ((_: String)->())?
    
    func initAnimals() -> UIView {
        
        unitX = UIScreen.main.bounds.width/10
        unitY = unitX
        
        let originX = unitX!
        let originY = UIScreen.main.bounds.height/2 - unitY * 4
        
        let boxRect = CGRect(x: originX, y: originY - unitY * 8, width: unitX * 8, height: unitY * 16)
        box = UIView(frame: boxRect)
        
        score = 0
        animals.removeAll()
        for i in 0...7 {
            for j in 0...7 {
                
                let x = unitX * CGFloat(j)
                let y = unitY * CGFloat(i) + unitY * 8
                guideX.insert(x)
                guideY.insert(y)
                
                let animal = createAnimal(x: x, y: y )
                animals.append(animal)
                box.addSubview(animal)
            }
        }
        
        return box
    }
    
    
    func createAnimal(x: CGFloat, y: CGFloat, icon: String? = nil) -> Animal {
        let idx = arc4random_uniform(UInt32(animalIcons.count))
        let icon = icon ?? animalIcons[Int(idx)]
        return Animal(x: x, y: y, unitX: unitX * 0.9, unitY: unitY, icon: icon, delegate: self)
    }
    
    func getNearbyAnimals(center: Animal) -> [Animal]{
        let centerIcon = center.text
        let centerX = center.frame.midX
        let centerY = center.frame.midY
        let nearby = animals.filter {
            let distX = abs($0.frame.midX - centerX)
            let distY = abs($0.frame.midY - centerY)
            return $0.text == centerIcon &&
            ( (distX <= unitX * 1.1 && distY < unitY * 0.2 ) ||
              (distY <= unitY * 1.1 && distX < unitX * 0.2 ) )
        }
        return nearby
    }
    
    func getAroundAnimals(core: Animal) -> [Animal] {
        var nearby = getNearbyAnimals(center: core)
        var around = Set<Animal>()
        var tempAround = around
        var extendNearby: [Animal]
        repeat {
            around = tempAround
            for animal in nearby {
                extendNearby = getNearbyAnimals(center: animal)
                
                for ext in extendNearby {
                    tempAround.insert(ext)
                }
            }
            nearby = Array(tempAround)
        }
        while (around.count != tempAround.count)
        return Array(around)
    }
    
    func twinkleAnimals(stop: Bool = false) {
        for animal in tappedAnimals {
            
            if stop {
                animal.alpha = 1
                animal.layer.removeAllAnimations()
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .repeat], animations: {
                    animal.alpha = 0.5
                })
            }
            
        }
    }
    
    func rotateAnimals(tapped: [Animal]) {
        for animal in tapped {
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                animal.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }) { done in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                    animal.transform = CGAffineTransform(rotationAngle: 0.0)
                })
            }
            
        }
    }
    
    func lineUpAnimals() {
        lineUps.removeAll()
        var lineUpList = [CGFloat:Int]()
        for animal in tappedAnimals {
            let x = animal.frame.minX
            if let count = lineUpList[x] {
                lineUpList[x] = count + 1
            } else {
                lineUpList[x] = 1
            }
            let newAnimal = createAnimal(x: x, y: unitY * CGFloat(8 - lineUpList[x]!) )
            lineUps.append(newAnimal)
            animals.append(newAnimal)
            box.addSubview(newAnimal)
        }
    }
    
    func byeAnimals() {
        for animal in tappedAnimals {
            UIView.animate(withDuration: 0.5, animations: {
                animal.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }) { done in
                animal.removeFromSuperview()
            }
            animals = animals.filter {
                !tappedAnimals.contains($0)
            }
        }
    }
    
    func fallingAnimals() {
        
        let gravity = UIGravityBehavior(items: animals)
        gravity.gravityDirection = CGVector(dx: 0, dy: 1)
        let collision = UICollisionBehavior(items: animals)
        collision.translatesReferenceBoundsIntoBoundary = true
        
        
        let itemBehavior = UIDynamicItemBehavior(items: animals)
        itemBehavior.allowsRotation = false
        
        anime = UIDynamicAnimator(referenceView: box)
        anime.addBehavior(gravity)
        anime.addBehavior(collision)
        
        let arrangeY = self.guideY.min()!
        DispatchQueue.global().async {
            var onFalling = true
            while onFalling {
                //Edit Scheme -> Diagnostics -> Disabled "Main Thread Checker" for the next line
                let animalY = self.lineUps.min { $0.frame.minY < $1.frame.minY }!.frame.minY
                if abs(animalY - arrangeY) < self.unitY * 0.1 {
                    onFalling = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.anime.removeAllBehaviors()
                self.arrangeAnimals()
            }
        }
    }
    
    func arrangeAnimals() {
        for id in animals.indices {
            let animalX = animals[id].frame.minX
            let animalY = animals[id].frame.minY
            let animalW = animals[id].frame.width
            let animalH = animals[id].frame.height
            let arrangedX = guideX.filter {
                abs($0 - animalX) < unitX * 0.5
            }[0]
            let arrangedY = guideY.filter {
                abs($0 - animalY) < unitY * 0.5
            }[0]
            
            UIView.animate(withDuration: 0.2, animations: {
                self.animals[id].frame = CGRect(x: arrangedX, y: arrangedY, width: animalW, height: animalH)
            }) { done in
                self.animals[id].removeFromSuperview()
                self.animals[id] = self.createAnimal(x: arrangedX, y: arrangedY, icon: self.animals[id].text)
                self.box.addSubview(self.animals[id])
            }
        }
        checkGameOver()
    }
    
    func checkGameOver() {
        var minAround = 0
        for animal in animals {
            let around = getAroundAnimals(core: animal)
            minAround = max(minAround, around.count)
        }
        if minAround < 3 {
            popGameOver?()
        }
    }
    var popGameOver: (()->())?
    
    func scoreToIcons(score: Int) -> String {
        if score == 0 {
            return "0️⃣0️⃣0️⃣0️⃣"
        } else {
            var score = score
            var scores = [String]()
            repeat {
                let digit = score % 10
                scores.insert(scoreIcons[digit], at: 0)
                score = score / 10
            } while (score > 0)
            return scores.joined()
        }
    }
    
}

extension MainViewModel: AnimalDelegate {
    func onTapDetected(_ animal: Animal) {
        if tappedAnimals.contains(animal) {
            _ = animals.map { $0.isUserInteractionEnabled = false }
            lineUpAnimals()
            byeAnimals()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.fallingAnimals()
            }
            score += Int(pow(Double(tappedAnimals.count), 6.0))
        } else {
            let around = getAroundAnimals(core: animal)
            if around.count < 3 {
                rotateAnimals(tapped: around)
                tappedAnimals.removeAll()
            } else {
                tappedAnimals = around
            }
        }
    }
}
