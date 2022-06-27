//
//  PhotoLibraryViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 26.06.2022.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    
    //MARK: - Properties
    var imagesFromLibrary = [UIImage]()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        ImageRepository.shared.requestAllImages(){ [weak self] images in
            DispatchQueue.main.async {
                self?.imagesFromLibrary.append(contentsOf: images.images)
                self?.imageView.image = self?.imagesFromLibrary.last
            }
        }

        
    }
    
}
