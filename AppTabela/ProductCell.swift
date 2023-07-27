//
//  ProductCell.swift
//  app_firebase
//
//  Created by user230281 on 12/5/22.
//

import UIKit
import FirebaseStorage

class ProductCell: UITableViewCell {

    @IBOutlet weak var productImage: LazyImageView!
    @IBOutlet weak var nameProduct: UILabel!
    @IBOutlet weak var codeProduct: UILabel!
    @IBOutlet weak var valueProduct: UILabel!
    @IBOutlet weak var classificationProduct: UILabel!
    @IBOutlet weak var typeProduct: UILabel!
    @IBOutlet weak var brandProduct: UILabel!
    @IBOutlet weak var indiceProduct: UILabel!
    @IBOutlet weak var antirreflexoPoduct: UILabel!
    @IBOutlet weak var fotossensivelProduct: UILabel!
    @IBOutlet weak var aditionProduct: UILabel!
    @IBOutlet weak var esfProduct: UILabel!
    @IBOutlet weak var cilProduct: UILabel!
    @IBOutlet weak var diameterProduct: UILabel!
    @IBOutlet weak var heightProduct: UILabel!
    
    let storage = Storage.storage().reference()
    
    var documentId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImage.layer.cornerRadius = productImage.frame.size.width / 2
        productImage.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
