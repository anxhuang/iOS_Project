//
//  PhotoListViewModel.swift
//  Gallery
//
//  Created by USER on 2018/10/31.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class PhotoListViewModel {
    
    var photos = [Photo]()
    var selectedPhoto: Photo?

    let apiService: APIServiceProtocol
    
    init (apiService: APIServiceProtocol = APIService() ) {
        self.apiService = apiService
    }
    
    func initFetch() {
        self.isLoading = true
        apiService.fetchPhoto { success, photos, error in
            self.isLoading = false
            if let error = error {
                self.alertMessage = error.rawValue
            }else{
                self.processFetchPhoto(photos: photos)
            }
        }
    }
    
    func processFetchPhoto(photos: [Photo]) {
        self.photos = photos
        var vms = [PhotoCellViewModel]()
        for photo in photos {
            vms.append(createCellViewModel(photo: photo))
        }
        cellViewModels = vms
    }
    
    func createCellViewModel(photo: Photo) -> PhotoCellViewModel {
        
        //descLabel
        var descTextArray = [String]()
        if let camera = photo.camera {
            descTextArray.append(camera)
        }
        if let description = photo.description {
            descTextArray.append(description)
        }
        let descText = descTextArray.joined(separator: " - ")
        
        //dateLabel
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateText = df.string(from: photo.created_at)
        
        return PhotoCellViewModel(titleText: photo.name,
                                  descText: descText,
                                  imageUrl: photo.image_url,
                                  dateText: dateText)
    }
    
    //reloadTableView
    private var cellViewModels = [PhotoCellViewModel]() {
        didSet {
            reloadTableViewClosure?()
        }
    }
    var reloadTableViewClosure: (() -> ())?
    
    var numOfCells: Int {
        return cellViewModels.count
    }
    
    func getCellViewModels (indexPath: IndexPath) -> PhotoCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    //alertMessage
    var alertMessage: String? {
        didSet {
            showAlertClosure?()
        }
    }
    var showAlertClosure: (() -> ())?
    
    //isLoading
    var isLoading = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    var updateLoadingStatus: (() -> ())?
    
    //userPressed
    var isAllowSegue = false
    func userPressed (at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        if photo.for_sale {
            isAllowSegue = true
            selectedPhoto = photo
        } else {
            isAllowSegue = false
            alertMessage = "This picture is not for sale"
        }

    }
}

struct PhotoCellViewModel {
    let titleText: String
    let descText: String
    let imageUrl: String
    let dateText: String
}
