//
//  PhotoDetailViewController.swift
//  Gallery
//
//  Created by USER on 2018/10/31.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet weak var fullImageView: UIImageView!
    
    var imageUrl: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        fullImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
    }

}
