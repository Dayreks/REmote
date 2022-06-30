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
    private var allPhotos = PHFetchResult<PHAsset>()
    var currentIndex = 0;
    var maxIndex = 0
    var emotionForCurrentLoad = ""
    
    static let shared = ImageRepository()
    
    public var imagesLoadedHandler: (() -> Void)?
    
    func requestAllImages(onCompleted: @escaping ([UIImage]) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                self.maxIndex = self.allPhotos.count
                print("Found \(String(describing: self.allPhotos.count)) assets")
                
                self.loadMoreImages(limit: 100)
                
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
            onCompleted(self.images)
        }
    }
    
    func checkFace(image: UIImage) -> Bool {
        let faceImage = CIImage(image: image)
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let faces = faceDetector?.features(in: faceImage!) as! [CIFaceFeature]
        if !faces.isEmpty {
            return true
        }
        return false
    }
    
    
    
    
    func loadMoreImages(limit: Int) {
            let contentMode: PHImageContentMode = .aspectFill
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            
            
            for i in (self.currentIndex...(self.currentIndex + limit)) {
                if(i <= self.maxIndex) {
                    PHImageManager.default().requestImage(for: self.allPhotos.object(at: i) as PHAsset, targetSize: CGSize(width: 200, height: 200), contentMode: contentMode, options: options) {
                        image, info in
                        guard let image = image else {return}
                    
                        if self.checkFace(image: image) {
                            self.images.append(image)
                        }
                        
                    }
                }
                self.currentIndex += 1
            }
            
        }
}

