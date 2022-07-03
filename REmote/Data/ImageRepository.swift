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
    var emotionForCurrentLoad = ""
    var takenPhoto: UIImage?
    
    
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
                print("Found \(String(describing: self.allPhotos.count)) assets")
                
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
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
    
    
    func takenPhotoEmotion() -> (String, UIImage?){
        guard let image = takenPhoto else {return ("No photo taken", nil)}
        let faceCheck = self.checkFace(image: image)
        var emotion = ""
        var face = UIImage()
        if (faceCheck.0) {
            let transformScale = CGAffineTransform(scaleX: 1, y: -1)
            let faceImage = CIImage(image: image)
            let transform = transformScale.translatedBy(x: 0, y: -faceImage!.extent.height)
            guard let cutImageRef: CGImage = image.cgImage?.cropping(to:faceCheck.1!.applying(transform)) else {return ("", nil)}
            
            let finalFace = rotateImage(UIImage(cgImage: cutImageRef), withAngle: 90)
            
            
            self.predictor.predict(image: finalFace!) { result in
                
                guard let maxItem = result!.max(by: {$0.1 < $1.1 }) else {return}
                print(maxItem)
                emotion = maxItem.0
                face = finalFace!
            }
        }
        else {
            return ("No face :(", nil)
        }
        return (emotion, face)
    }
    
    func rotateImage(_ image: UIImage, withAngle angle: Double) -> UIImage? {
        if angle.truncatingRemainder(dividingBy: 360) == 0 { return image }
        
        let imageRect = CGRect(origin: .zero, size: image.size)
        let radian = CGFloat(angle / 180 * .pi)
        let rotatedTransform = CGAffineTransform.identity.rotated(by: radian)
        var rotatedRect = imageRect.applying(rotatedTransform)
        rotatedRect.origin.x = 0
        rotatedRect.origin.y = 0
        
        UIGraphicsBeginImageContext(rotatedRect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)
        context.rotate(by: radian)
        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
        image.draw(at: .zero)
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    func loadMoreImages(limit: Int) {
        let contentMode: PHImageContentMode = .aspectFill
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        
        for i in (self.currentIndex...(self.currentIndex + limit)) {
            if (self.currentIndex > self.allPhotos.count){
                return
            }
            PHImageManager.default().requestImage(for: self.allPhotos.object(at: i) as PHAsset, targetSize: CGSize(width: 200, height: 200), contentMode: contentMode, options: options) {
                image, info in
                guard let image = image else {return}
                
                let faceCheck = self.checkFace(image: image)
                
                if faceCheck.0 {
                    let transformScale = CGAffineTransform(scaleX: 1, y: -1)
                    let faceImage = CIImage(image: image)
                    let transform = transformScale.translatedBy(x: 0, y: -faceImage!.extent.height)
                    guard let cutImageRef: CGImage = image.cgImage?.cropping(to:faceCheck.1!.applying(transform)) else {return}
                    
                    DispatchQueue.global(qos: .userInteractive).async {
                        self.predictor.predict(image: UIImage(cgImage: cutImageRef)){ result in
                            DispatchQueue.main.async {
                                guard let maxItem = result!.max(by: {$0.1 < $1.1 }) else {return}
                                print(maxItem)
                                
                                switch maxItem.0.lowercased() {
                                case "angry":
                                    EmotionsData.shared.angry.append(UIImage(cgImage: cutImageRef))
                                case "happy":
                                    EmotionsData.shared.happy.append(UIImage(cgImage: cutImageRef))
                                case "sad":
                                    EmotionsData.shared.sad.append(UIImage(cgImage: cutImageRef))
                                case"disgust":
                                    EmotionsData.shared.disgust.append(UIImage(cgImage: cutImageRef))
                                case "fear":
                                    EmotionsData.shared.fear.append(UIImage(cgImage: cutImageRef))
                                case "neutral" :
                                    EmotionsData.shared.neutral.append(UIImage(cgImage: cutImageRef))
                                case "surprise" :
                                    EmotionsData.shared.surprise.append(UIImage(cgImage: cutImageRef))
                                default:
                                    print("No matching emotion")
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


class EmotionsData{
    
    static let shared = EmotionsData()
    
    var angry: [UIImage] = []
    var happy: [UIImage] = []
    var sad: [UIImage] = []
    var disgust: [UIImage] = []
    var fear: [UIImage] = []
    var neutral: [UIImage] = []
    var surprise: [UIImage] = []
    
}

