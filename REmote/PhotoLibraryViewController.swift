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
    lazy var imagesFromLibrary = [UIImage]()
    let getImages = GetImages()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getImages.requestAllImages(){ [weak self] images in
            DispatchQueue.main.async {
                self?.imagesFromLibrary.append(contentsOf: images.images)
                print(self?.imagesFromLibrary.count)
                self?.imageView.image = self?.imagesFromLibrary.last
            }
        }

        
    }
    
}

class GetImages {
    var images = [UIImage]()
    
    func requestAllImages(onCompleted: @escaping (GetImages) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self] status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) assets")
                let contentMode: PHImageContentMode = .aspectFill
                
                allPhotos.enumerateObjects {
                    object, index, stop in
                    
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.deliveryMode = .highQualityFormat
                    
                    PHImageManager.default().requestImage(for: object as PHAsset, targetSize: CGSize(width: object.pixelWidth, height: object.pixelHeight), contentMode: contentMode, options: options) {
                        image, info in
                        guard let image = image else {return}
                        self.images.append(image)
                    }
                }
                print(images.count)
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
            
            onCompleted(self)
        }
    }
}


