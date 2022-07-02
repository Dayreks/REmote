//
//  Predictor.swift
//  FaceEmoji
//
//  Created by Master on 29.06.2022.
//

import UIKit
import Vision

typealias EmotionResult = (String, Float)

public class EmotionCheck {
    
    private var compl: (([EmotionResult]?) -> Void)?
    
    var model: VNCoreMLModel = {
        let conf = MLModelConfiguration()
        let baseModel = try! CNNEmotions(configuration: conf)
        return try! VNCoreMLModel(for: baseModel.model)
    }()
    
    func predict(image: UIImage, faceBounds: CGRect?, complition: @escaping ([EmotionResult]?) -> Void) {
        self.compl = complition
        let request = classificationRequest()
        guard let cutImageRef: CGImage = image.cgImage?.cropping(to:faceBounds!) else {return}
        let handler = VNImageRequestHandler(
            cgImage: cutImageRef,
            orientation: CGImagePropertyOrientation(image.imageOrientation)
        )
        
        do{
            try handler.perform([request])
        } catch{
           print(error)
        }    }
    
    private func classificationRequest() -> VNImageBasedRequest {
        let req = VNCoreMLRequest(model: model, completionHandler: requestComplitionHandler)
        req.imageCropAndScaleOption = .centerCrop
        return req
    }
    
    private func requestComplitionHandler(_ request: VNRequest, error: Error?){
        guard let obser = request.results as? [VNClassificationObservation]
        else{ return }
        compl?(obser.map{($0.identifier, $0.confidence)})
    }
}


extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
            case .up: self = .up
            case .down: self = .down
            case .left: self = .left
            case .right: self = .right
            case .upMirrored: self = .upMirrored
            case .downMirrored: self = .downMirrored
            case .leftMirrored: self = .leftMirrored
            case .rightMirrored: self = .rightMirrored
            @unknown default: self = .up
        }
    }
}

