//
//  LenImageCell.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 17/03/23.
//

import UIKit

class LenImageCell: UICollectionViewCell {
    @IBOutlet weak var BrandImageCell: LazyImageView!
    
    var urlPhoto = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        BrandImageCell.image = UIImage(systemName: "photo")
        
    }
}
