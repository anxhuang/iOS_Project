//
//  APIServiceTests.swift
//  GalleryTests
//
//  Created by USER on 2018/11/1.
//  Copyright © 2018 Macchier. All rights reserved.
//

import XCTest
@testable import Gallery

class APIServiceTests: XCTestCase {
    
    var sut: APIService?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = APIService()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func test_fetch_photo() {
        
        //Given
        let stubPhotos = StubGenerator().stubPhotos()
        let expect = XCTestExpectation(description: "fetch photo completion called")
        
        //When
        sut!.fetchPhoto { success, photos, error in
            expect.fulfill()
            XCTAssertEqual(stubPhotos.count, photos.count)
            for photo in photos {
                XCTAssertNotNil(photo.id)
            }
        }
        
        //Assert
        wait(for: [expect], timeout: 3.1) //timeout should include the sleep time
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
