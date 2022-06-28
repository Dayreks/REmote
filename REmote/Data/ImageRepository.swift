//
//  ImageRepository.swift
//  REmote
//
//  Created by Bohdan on 27.06.2022.
//

import Foundation
import UIKit
import Photos
import Vision

class ImageRepository {
    var images: [UIImage] = [] {
        didSet {
            imagesLoadedHandler?()
        }
    }
    var emotionRecognizedImages = [UIImage]()
    
    static let shared = ImageRepository()
    
    public var imagesLoadedHandler: (() -> Void)?
    
    func requestAllImages(onCompleted: @escaping ([UIImage]) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) assets")
                let contentMode: PHImageContentMode = .aspectFill
                
                allPhotos.enumerateObjects {
                    object, index, stop in
                    
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.deliveryMode = .highQualityFormat
                    
                    PHImageManager.default().requestImage(for: object as PHAsset, targetSize: CGSize(width: 200, height: 200), contentMode: contentMode, options: options) {
                        image, info in
                        guard let image = image else {return}
                        
                        //Check if they have a face
                        let faceImage = CIImage(image: image)
                        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
                        let faces = faceDetector?.features(in: faceImage!) as! [CIFaceFeature]

                        if !faces.isEmpty {
                            self?.images.append(image)
                        }
                              
                    }
                }
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
            guard let imgs = self?.images else { return }
            
            onCompleted(imgs)
        }
    }
}

