//
//  photo.swift
//  Gallery
//
//  Created by USER on 2018/10/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import Foundation

struct Photos: Codable{
    let photos: [Photo]
}

struct Photo: Codable {
    let id: Int
    let name: String
    let description: String?
    let created_at: Date
    let image_url: String
    let for_sale: Bool
    let camera: String?
}
