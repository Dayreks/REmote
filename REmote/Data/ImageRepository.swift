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
    var allPhotos = PHFetchResult<PHAsset>()
    var currentIndex = 0;
    var maxIndex = 0
    var emotionForCurrentLoad = ""
    
    private let predictor = EmotionCheck()
    
    
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
    
    func checkFace(image: UIImage) -> (Bool, CGRect?) {
        let faceImage = CIImage(image: image)
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let faces = faceDetector?.features(in: faceImage!) as! [CIFaceFeature]
        if !faces.isEmpty {
            guard let bounds = faces.first?.bounds else {return (true, nil)}
            return (true,bounds)
        }
        return (false, nil)
    }

    
    private func showPrediction(predictions: [EmotionCheck]?){
    }
    
    func loadMoreImages(limit: Int) {
        let contentMode: PHImageContentMode = .aspectFill
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        
        for i in (self.currentIndex...(self.currentIndex + limit)) {
            if(i <= self.maxIndex) {
                PHImageManager.default().requestImage(for: self.allPhotos.object(at: i) as PHAsset, targetSize: CGSize(width: 500, height: 500), contentMode: contentMode, options: options) {
                    image, info in
                    guard let image = image else {return}
                    
                    let faceCheck = self.checkFace(image: image)
                    
                    if faceCheck.0 {
                        let transformScale = CGAffineTransform(scaleX: 1, y: -1)
                        let faceImage = CIImage(image: image)
                        let transform = transformScale.translatedBy(x: 0, y: -faceImage!.extent.height)
                        guard let cutImageRef: CGImage = image.cgImage?.cropping(to:faceCheck.1!.applying(transform)) else {return}
                        
                        DispatchQueue.global(qos: .userInteractive).async {
                            self.predictor.predict(image: UIImage(cgImage: cutImageRef), faceBounds: faceCheck.1){ result in
                                DispatchQueue.main.async {
                                    guard let maxItem = result!.max(by: {$0.1 < $1.1 }) else {return}
                                    print(maxItem)
                                    if (maxItem.0.lowercased() == self.emotionForCurrentLoad.lowercased()){
                                        self.images.append(UIImage(cgImage: cutImageRef))
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            self.currentIndex += 1
        }
        
    }
}

