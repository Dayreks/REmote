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

        requestAllImages()
        
        self.imageView.image = imagesFromLibrary.first
//        self.view.addSubview(UIImageView(image: imagesFromLibrary.first))
        
    }
    
    
    func requestAllImages() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) assets")
                self.imagesFromLibrary.append((allPhotos.firstObject?.getImageForAsset())!)
                print(self.imagesFromLibrary.count)
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

extension PHAsset {
    func getImageForAsset() -> UIImage {
        let manager = PHImageManager.default
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager().requestImage(for: self, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: nil, resultHandler: {(result, info) -> Void in
                thumbnail = result!
        })
        return thumbnail
    }
}
