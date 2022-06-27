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
        
        ImageRepository.shared.requestAllImages(){
            DispatchQueue.main.async {
                self.table.reloadData()
                print(ImageRepository.shared.images.count)
            }
        }
        print(ImageRepository.shared.faceDetectedImages.count)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImageRepository.shared.faceDetectedImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath) as! ImageCell
        cell.configureView(image: ImageRepository.shared.faceDetectedImages[indexPath.row])
        return cell
    }
    
    
    
}
