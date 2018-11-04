//
//  APIService.swift
//  Gallery
//
//  Created by USER on 2018/10/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation

protocol APIServiceProtocol {
    func fetchPhoto( completion: @escaping (_ success: Bool, _ photos: [Photo], _ error: APIError? ) -> ())
}

class APIService: APIServiceProtocol {
    func fetchPhoto( completion: @escaping (_ success: Bool, _ photos: [Photo], _ error: APIError? ) -> ()) {
        DispatchQueue.global().async {
            sleep(3)
            let path = Bundle.main.path(forResource: "content", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try! decoder.decode(Photos.self, from: data)
            completion(true, photos.photos, nil)
        }
    }
    
    
}

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is Overload"
    case permissionDenied = "You don't have permission"
}
