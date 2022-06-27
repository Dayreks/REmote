//
//  ImageCell.swift
//  REmote
//
//  Created by Bohdan on 27.06.2022.
//

import Foundation
import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet private weak var picture: UIImageView!
    
    func configureView(image: UIImage) {
        self.picture.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
