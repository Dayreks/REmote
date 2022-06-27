//
//  PhotoLibraryViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 26.06.2022.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController,UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate {
    
    
    //MARK: - Properties
    
    //MARK: - Outlets
    @IBOutlet weak var table: UITableView!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.dataSource = self
        self.table.delegate = self
        ImageRepository.shared.requestAllImages() { imgs in
            ImageRepository.shared.images.append(contentsOf: imgs)
        }
        
        ImageRepository.shared.imagesLoadedHandler = {
            self.reloadDataAsync()
        }
        
//        print(ImageRepository.shared.faceDetectedImages.count)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImageRepository.shared.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath) as! ImageCell
        cell.configureView(image: ImageRepository.shared.images[indexPath.row])
        print("table view\(ImageRepository.shared.images.count)")
        return cell
    }
    
    private func reloadDataAsync() {
        DispatchQueue.main.async { [weak self] in
            self?.table.reloadData()
        }
    }
    
    
}
