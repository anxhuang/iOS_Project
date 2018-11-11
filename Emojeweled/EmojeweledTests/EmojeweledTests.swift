//
//  EmojeweledTests.swift
//  EmojeweledTests
//
//  Created by USER on 2018/11/2.
//  Copyright © 2018 Macchier. All rights reserved.
//

import XCTest
@testable import Emojeweled

class EmojeweledTests: XCTestCase {
    
    var mockVM: MockMainViewModel!
    var sut: MainViewModel!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockVM = MockMainViewModel()
        sut = MainViewModel()
        
        _ = sut.initAnimals()
        
        sut.box = mockVM.initAnimals() //Mock Pattern Data Injection
        sut.animals = mockVM.animals //Mock Pattern Data Injection
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockVM = nil
        sut = nil
    }
    
    func test_initAnimal() {
        
        //Given
        let mvm = MainViewModel()
        mvm.score = 987654321
        mvm.animals = mockVM.getStubGameOverAnimals()
        
        //When
        let box: UIView = mvm.initAnimals()
        
        //Assert
        XCTAssertEqual(mvm.score, 0)
        XCTAssertNotNil(mvm.box)
        XCTAssertEqual(mvm.box, box)
        XCTAssertNotNil(mvm.unitX)
        XCTAssertEqual(mvm.unitX, mvm.unitY)
        XCTAssertEqual(mvm.animals.count, 64)
        XCTAssertEqual(box.subviews.count, 64)
    }
    
    func test_createAnimal() {
        //Given
        let stubX: CGFloat = 111.111
        let stubY: CGFloat = 222.222
        let stubIcon = "🐱"
        let stubAnimal = Animal(x: stubX, y: stubY, unitX: sut.unitX * 0.9, unitY: sut.unitY, icon: stubIcon, delegate: sut)
        
        //When
        let animal = sut.createAnimal(x: stubX, y: stubY, icon: stubIcon)
        
        //Assert
        XCTAssertEqual(animal.frame.midX, stubAnimal.frame.midX)
        XCTAssertEqual(animal.frame.midY, stubAnimal.frame.midY)
        XCTAssertEqual(animal.frame.width, stubAnimal.frame.width)
        XCTAssertEqual(animal.frame.height, stubAnimal.frame.height)
        XCTAssertEqual(animal.text, stubAnimal.text)
        XCTAssertNotNil(animal.delegate)
    }

    func test_getNearByAnimals() {
        //Given
        let stubAnimal = sut.animals[27]
        let stubNearBy = [sut.animals[27], sut.animals[28], sut.animals[35]]
        
        //When
        let nearby = sut.getNearbyAnimals(center: stubAnimal)
        
        //Assert
        XCTAssertEqual(nearby, stubNearBy)
    }
    
    func test_getAroundAnimals() {
        //Given
        let stubAnimal = sut.animals[9]
        let stubAround = mockVM.getStubTappedAnimal().sorted() { $0.hash < $1.hash }
        
        //When
        let around = sut.getAroundAnimals(core: stubAnimal).sorted() { $0.hash < $1.hash }
        
        //Assert
        XCTAssertEqual(around, stubAround)
    }

    func test_twinkleAnimals() {
        //Given
        sut.tappedAnimals = mockVM.getStubTappedAnimal()
        
        //When
        // => twinkleAnimals auto triggered when set .tappedAnimals
        
        //Assert
        for twinkling in sut.tappedAnimals {
            XCTAssertNotNil(twinkling.layer.animationKeys())
        }
        
        sut.twinkleAnimals(stop: true)
        
        for stopped in sut.tappedAnimals {
            XCTAssertEqual(stopped.alpha, 1.0)
            XCTAssertNil(stopped.layer.animationKeys())
        }
    }
    
    func test_rotateAnimals() {
        //Given
        let stubTapped = mockVM.getStubTappedAnimal()
        
        //When
        sut.rotateAnimals(tapped: stubTapped)
        
        //Assert
        for rotated in stubTapped {
            XCTAssertNotNil(rotated.layer.animationKeys())
            XCTAssertNotNil(rotated.layer.animationKeys())
        }
    }
    
    func test_lineUpAnimals() {
        //Given
        sut.tappedAnimals = mockVM.getStubTappedAnimal()
        let sum = sut.tappedAnimals.count + 64
        
        //When
        sut.lineUpAnimals()
        
        //Assert
        XCTAssertEqual(sut.lineUps.count, sut.tappedAnimals.count )
        XCTAssertEqual(sut.animals.count, sum)
        XCTAssertEqual(sut.box.subviews.count, sum)
    }
    
    func test_byeAnimals() {
        //Given
        sut.tappedAnimals = mockVM.getStubTappedAnimal()
        
        //When
        sut.byeAnimals()
        
        //Assert
        for bye in sut.tappedAnimals {
            XCTAssertFalse(sut.animals.contains(bye))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                XCTAssertFalse(self.sut.box.subviews.contains(bye))
            }
        }
    }

    func test_fallingAnimals() {
        //Given
        sut.animals = mockVM.getStubTappedAnimal()
        sut.lineUps = sut.animals
        
        //When
        sut.fallingAnimals()
        
        //Assert
        XCTAssertEqual(sut.anime.behaviors.count, 2)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            XCTAssertNil(self.sut.anime.behaviors)
        }
    }
    
    func test_arrangeAnimals() {
        //Given
        sut.animals = mockVM.getStubTappedAnimal()
        let stubX = sut.animals[0].frame.midX
        let stubY = sut.animals[0].frame.midY
        let stubIcon = sut.animals[0].text
        sut.animals[0].frame = CGRect(
            x: stubX + 0.5 ,
            y: stubY - 0.5 ,
            width: sut.animals[0].frame.width,
            height: sut.animals[0].frame.height)
        
        //When
        sut.arrangeAnimals()
        
        //Assert
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.sut.animals[0].frame.midX, stubX)
            XCTAssertEqual(self.sut.animals[0].frame.midY, stubY)
            XCTAssertEqual(self.sut.animals[0].text, stubIcon)
        }
    }
    
    func test_checkGameOverTrue() { // for Game Over
        //Given
        sut.animals = mockVM.getStubGameOverAnimals()
        let expect = XCTestExpectation(description: "Is Pop Game Over")
        sut.popGameOver = {
            expect.fulfill()
        }
        
        //When
        sut.checkGameOver()
        
        //Assert
        wait(for: [expect], timeout: 0.5)
    }
    
    func test_checkGameOverFalse() { // for Game Not Over
        //Given
        sut.popGameOver = {
            XCTFail("Error for Game is Not Over")
        }
        
        //When
        sut.checkGameOver()
        
        //Assert
        // => assigned in Given
    }
    
    func test_scoreToIcon() {
        //Given
        var zero: String!
        var nineToOne: String!
        
        //When
        zero = sut.scoreToIcons(score: 0)
        nineToOne = sut.scoreToIcons(score: 987654321)
        
        //Assert
        XCTAssertEqual(zero, "0️⃣0️⃣0️⃣0️⃣")
        XCTAssertEqual(nineToOne, "9️⃣8️⃣7️⃣6️⃣5️⃣4️⃣3️⃣2️⃣1️⃣")
    }
    
    func test_renewScoreLabel() {
        //Given
        var nineToOne: String!
        let expect = XCTestExpectation(description: "Scored renewed")
        sut.renewScoreLabel = { scoreString in
            expect.fulfill()
            nineToOne = scoreString
        }
        
        //When
        sut.score = 987654321
        
        //Assert
        XCTAssertEqual(nineToOne, "9️⃣8️⃣7️⃣6️⃣5️⃣4️⃣3️⃣2️⃣1️⃣")
        
        wait(for: [expect], timeout: 0.5)
    }
    
    func test_onTapDetected() {
        //Given
        let stubAnimal = sut.animals[9]
        let stubAround = mockVM.getStubTappedAnimal().sorted() {$0.hash < $1.hash}
        
        //When
        sut.onTapDetected(stubAnimal)
        
        //Assert
        let around = sut.tappedAnimals.sorted() {$0.hash < $1.hash}
        XCTAssertEqual(around, stubAround)
        
        //When (tapped 2nd times)
        sut.onTapDetected(sut.tappedAnimals[9])
        
        //Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            for bye in around {
                XCTAssertFalse(self.sut.animals.contains(bye))
            }
            let stubScore = Int(pow(Double(around.count), 6.0))
            XCTAssertEqual(self.sut.score, stubScore)
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class MockMainViewModel: MainViewModel {
    
    /*
     
     animalIcons = ["🐶","🦊","🐻","🐯","🐮"]
     
     Stub Patttern
     00 🐶🐶🐶🐶🐶🐶🐶🐶
     08 🐶🐶🐻🐯🐻🐮🐻🐮
     16 🐶🦊🐶🦊🦊🦊🦊🦊
     24 🐶🐯🐻🐶🐶🐶🐶🐶
     32 🐶🦊🦊🐶🐶🐶🐶🐶
     40 🐶🐮🐻🐶🐶🐶🐶🐶
     48 🐶🦊🦊🐶🐶🐶🐶🐶
     56 🐶🐮🐻🐶🐶🐶🐶🐶
     
     */
    
    override func initAnimals() -> UIView {
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
                
                var icon: String!
                if i == j || (i > 2 && j > 2) || (i == 0 || j == 0){
                    icon = animalIcons[0]
                } else if i % 2 == 0 {
                    icon = animalIcons[1]
                } else if j % 2 == 0 {
                    icon = animalIcons[2]
                } else if i < 4 && j < 4 {
                    icon = animalIcons[3]
                } else {
                    icon = animalIcons[4]
                }
                
                let animal = Animal(x: x, y: y, unitX: unitX * 0.9 , unitY: unitY, icon: icon, delegate: self)
                animals.append(animal)
                box.addSubview(animal)
            }
        }
        
//        var k = 0
//        for _ in 0...7 {
//            for _ in 0...7 {
//                print(animals[k].text!, terminator: "")
//                k += 1
//            }
//            print()
//        }
        
        return box
    }
    
    
    func getStubTappedAnimal() -> [Animal] {
        
        /*
         
         Stub Patttern
         01 🐶🐶🐶🐶🐶🐶🐶🐶
         07 🐶🐶<- 00
         10 🐶
         11 🐶
         12 🐶
         13 🐶
         14 🐶
         15 🐶
         
         */
        
        var stub = [animals[9]]
        var k = 0
        for i in 0...7 {
            for j in 0...7 {
                if i == 0 || j == 0 {
                    stub.append(animals[k])
                }
                k += 1
            }
        }
        return stub
    }
    
    func getStubGameOverAnimals() -> [Animal] {
        
        /*
         
         Stub Patttern
         00 🐶🐻🐯🐻
         04 🦊🐶🦊🦊
         08 🐯🐻🐶🐶
         
         */
        
        var stub = [Animal]()
        var k = 0
        for i in 0...7 {
            for j in 0...7 {
                if 0 < i && i < 4 && 0 < j && j < 5 {
                    stub.append(animals[k])
                }
                k += 1
            }
        }
        
//        k = 0
//        for _ in 1...3 {
//            for _ in 1...4 {
//                print(stub[k].text!, terminator: "")
//                k += 1
//            }
//            print()
//        }
        
        return stub
    }
    
}
