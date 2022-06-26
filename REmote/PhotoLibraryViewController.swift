//
//  PhotoLibraryViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 26.06.2022.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController {

    //MARK: - Properties
    var imagesFromLibrary = [UIImage]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        requestAllImages()
    }
    
    
    func requestAllImages() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) assets")
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            case .limited:
                print("(limited)")
            @unknown default:
                break
            }
            
        }
    }

    

}
