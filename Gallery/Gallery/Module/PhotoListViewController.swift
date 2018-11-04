//
//  PhotoListViewController.swift
//  Gallery
//
//  Created by USER on 2018/10/30.
//  Copyright © 2018 Macchier. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var viewModel: PhotoListViewModel = {
        return PhotoListViewModel()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Popular"
        
        //Binding
        viewModel.showAlertClosure = { () in
            DispatchQueue.main.async {
                if let message = self.viewModel.alertMessage {
                    self.showAlert(message: message)
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { () in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.updateLoadingStatus = { () in
            DispatchQueue.main.async {
                if self.viewModel.isLoading {
                    self.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.5) {
                        self.tableView.alpha = 0.0
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.5) {
                        self.tableView.alpha = 1.0
                    }
                }
            }
        }
        
        viewModel.initFetch()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }


}

extension PhotoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoTableViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        let cellVM = viewModel.getCellViewModels(indexPath: indexPath)
        cell.nameLabel.text = cellVM.titleText
        cell.descLabel.text = cellVM.descText
        cell.dateLabel.text = cellVM.dateText
        cell.backImageView?.sd_setImage(with: URL(string: cellVM.imageUrl), completed: nil)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        viewModel.userPressed(at: indexPath)
        if viewModel.isAllowSegue {
            return indexPath
        }else{
            return nil
        }
    }
    
}

extension PhotoListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoDetailViewController {
            if let photo = viewModel.selectedPhoto {
                vc.imageUrl = photo.image_url
            }
        }
    }
}

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        selectionStyle = .none
    }
}
