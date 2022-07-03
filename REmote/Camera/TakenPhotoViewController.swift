//
//  TakenPhotoViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 03.07.2022.
//

import UIKit

class TakenPhotoViewController: UIViewController {

    @IBOutlet private weak var takenPhotoImageView: UIImageView!
    @IBOutlet private weak var emotionLabel: UILabel!
    
    var image: UIImage? = nil
    var emotion: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = ImageRepository.shared.takenPhotoEmotion()
        self.takenPhotoImageView.image = data.1
        self.emotionLabel.text = data.0
        self.emotionLabel.layer.masksToBounds = true
        self.emotionLabel.layer.cornerRadius = 10
        
    }
    

    
    

}
