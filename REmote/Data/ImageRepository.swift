//
//  ImageRepository.swift
//  REmote
//
//  Created by Bohdan on 27.06.2022.
//

import Foundation
import UIKit
import Photos


class ImageRepository {
    var images = [UIImage]()
    var faceDetectedImages = [UIImage]()
    var emotionRecognizedImages = [UIImage]()
    
    static let shared = ImageRepository()
    
    func requestAllImages(onCompleted: @escaping () -> Void) {
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
                    
                    PHImageManager.default().requestImage(for: object as PHAsset, targetSize: CGSize(width: 300, height: 300), contentMode: contentMode, options: options) {
                        image, info in
                        guard let image = image else {return}
                        
                        //Check if they have a face
                        let ciImage = CIImage(cgImage: image.cgImage!)
                        
                        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
                        
                        let faces = faceDetector.features(in: ciImage)
                        
                        if faces.first is CIFaceFeature {
                            self?.faceDetectedImages.append(image)
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
            onCompleted()
        }
    }
}

