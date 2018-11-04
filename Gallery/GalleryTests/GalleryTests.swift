//
//  GalleryTests.swift
//  GalleryTests
//
//  Created by USER on 2018/10/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import XCTest
@testable import Gallery

class GalleryTests: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var sut: PhotoListViewModel!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockAPIService = MockAPIService()
        sut = PhotoListViewModel(apiService: mockAPIService)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockAPIService = nil
        sut = nil
    }
    
    func test_fetch_photo() {
        
        //Given
        //mockAPIService.fetchedPhotos = [Photo]()
        
        //When
        sut.initFetch()
        
        //Assert
        XCTAssert(mockAPIService.isFetchPhotoCalled)
    }
    
    func test_fetch_photo_fail() {
        
        //Given
        let error = APIError.permissionDenied //Modify this to pick any APIError you want to test
        
        //When
        sut.initFetch()
        mockAPIService.fetchFailed(error: error)
        
        //Assert
        XCTAssertEqual(sut.alertMessage, error.rawValue)
    }
    
    func test_loading_when_fetch() {
        
        //Given
        var loadingStatus = false //For assert different status from the same property, stored the property.
        let expect = XCTestExpectation(description: "Loading status updated")
        sut.updateLoadingStatus = { [weak sut] in //weak makes "sut" in the closure may ignore "self."
            expect.fulfill()
            loadingStatus = sut!.isLoading
        }
        
        //When
        sut.initFetch()
        XCTAssertTrue(loadingStatus)
        
        mockAPIService.fetchSuccess()
        
        //Assert
        XCTAssertFalse(loadingStatus)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_user_press_for_sale_item() {
        
        //Given
        let indexPath = IndexPath(row: 0, section: 0)
        gotoFetchFinished()
        
        //When
        sut.userPressed(at: indexPath)
        
        //Assert
        XCTAssert(sut.isAllowSegue)
        XCTAssertNotNil(sut.selectedPhoto)
    }
    
    func test_user_press_not_for_sale_item() {
        
        //Given
        let indexPath = IndexPath(row: 4, section: 0)
        gotoFetchFinished()
        
        let expect = XCTestExpectation(description: "Alert not for sale is shown")
        sut.showAlertClosure = { [weak sut] in
            expect.fulfill()
            XCTAssertEqual(sut!.alertMessage, "This picture is not for sale")
        }
        
        //When
        sut.userPressed(at: indexPath)
        
        //Assert
        XCTAssert(!sut.isAllowSegue)
        XCTAssertNil(sut.selectedPhoto)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_preocess_fetch_photos() {
        
        //Given
        let photos = StubGenerator().stubPhotos()
        mockAPIService.fetchedPhotos = photos
        let expect = XCTestExpectation(description: "reload table called")
        sut.reloadTableViewClosure = { () in
            expect.fulfill()
        }
        
        //When
        sut.initFetch()
        mockAPIService.fetchSuccess() //include sut.processFetchPhoto(photos: photos)
        
        //Assert
        XCTAssertEqual(sut.numOfCells, photos.count)
        
        wait(for: [expect], timeout: 1.0)
    }
    
    func test_get_cell_view_model() {
        
        //Given
        gotoFetchFinished()
        let indexPath = IndexPath(row: 1, section: 0)
        let testPhoto = mockAPIService.fetchedPhotos[indexPath.row]
        
        //When
        let cvm = sut.getCellViewModels(indexPath: indexPath)
        
        //Assert
        XCTAssertEqual(cvm.titleText, testPhoto.name)
        
    }
    
    func test_create_cell_view_model() {
        
        //Given
        let today = Date()
        let photoNormal = Photo(id: 1, name: "name", description: "desc", created_at: today, image_url: "url", for_sale: true, camera: "Cam")
        let photoWithoutCamera = Photo(id: 1, name: "name", description: "desc", created_at: today, image_url: "url", for_sale: true, camera: nil)
        let photoWithoutDescription = Photo(id: 1, name: "name", description: nil, created_at: today, image_url: "url", for_sale: true, camera: "Cam")
        let photoWithoutBoth = Photo(id: 1, name: "name", description: nil, created_at: today, image_url: "url", for_sale: true, camera: nil)
        
        
        //When
        let cvmNormal = sut.createCellViewModel(photo: photoNormal)
        let cvmWithoutCamera = sut.createCellViewModel(photo: photoWithoutCamera)
        let cvmWithoutDescription = sut.createCellViewModel(photo: photoWithoutDescription)
        let cvmWithoutBoth = sut.createCellViewModel(photo: photoWithoutBoth)
        
        //Assert
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let photoDateText = df.string(from: today)
        XCTAssertEqual(cvmNormal.titleText, photoNormal.name)
        XCTAssertEqual(cvmNormal.imageUrl, photoNormal.image_url)
        XCTAssertEqual(cvmNormal.dateText, photoDateText)
        
        let photoDescText = photoNormal.camera!+" - "+photoNormal.description!
        XCTAssertEqual(cvmNormal.descText, photoDescText)
        XCTAssertEqual(cvmWithoutCamera.descText, photoWithoutCamera.description)
        XCTAssertEqual(cvmWithoutDescription.descText, photoWithoutDescription.camera)
        XCTAssertEqual(cvmWithoutBoth.descText, "")
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

extension GalleryTests {
    func gotoFetchFinished() {
        mockAPIService.fetchedPhotos = StubGenerator().stubPhotos()
        sut.initFetch()
        mockAPIService.fetchSuccess()
    }
}


class MockAPIService: APIServiceProtocol {
    
    var isFetchPhotoCalled = false
    var fetchedPhotos = [Photo]() //Array of stubs
    var completionClosure: ((Bool, [Photo], APIError?) -> ())!
    
    func fetchPhoto(completion: @escaping (Bool, [Photo], APIError?) -> ()) {
        isFetchPhotoCalled = true
        completionClosure = completion
    }
    
    func fetchSuccess() {
        completionClosure(true, fetchedPhotos, nil) //Return stubs instead of empty array
    }
    
    func fetchFailed(error: APIError) {
        completionClosure(false, fetchedPhotos, error)
    }
    
}

class StubGenerator {
    func stubPhotos() -> [Photo] {
        let path = Bundle.main.path(forResource: "content", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let photos = try! decoder.decode(Photos.self, from: data)
        return photos.photos
    }
}
