//
//  PhotoCollectionViewCell.swift
//  REmote
//
//  Created by Dmytro Hetman on 28.06.2022.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    func config(image: UIImage) {
        self.imageView.image = image
    }

}
