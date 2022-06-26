//
//  ImageSaver.swift
//  REmote
//
//  Created by Dmytro Hetman on 26.06.2022.
//

import UIKit

class ImageSaver: NSObject {
    
    func writeToUserLibrary(image: UIImage?) {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Success")
        }
    }
    
}
