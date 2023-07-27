//
//  ModalImageController.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 5/6/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class ModalImageController: UIViewController {
    
    var brandsImages: [String] = []
    var photoSelected: String = ""
    
    let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    @IBOutlet weak var ImagesCollectionView: UICollectionView!
    
    weak var previousViewController: RegisterProductsViewController?
    weak var editPreviousController: EditProductViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ImagesCollectionView.dataSource = self
        ImagesCollectionView.delegate = self
        
        if ImagesCollectionView != nil {
            print("A tabela deveria aparecer")
        }
        
        loadImages()
    }
    
    func loadImages() {
        let storageRef = storage.child("brands")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error in find images \(error.localizedDescription)")
            }else {
                for item in result!.items {
                    item.downloadURL { (url, error) in
                        if let error = error {
                            print("Error in find url image \(error.localizedDescription)")
                        } else {
                            let imageUrl = url!.absoluteString
                            self.brandsImages.append(imageUrl)
                            self.ImagesCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

}

extension ModalImageController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brandsImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LenCellModal", for: indexPath) as! LenImageCell
        
        cell.urlPhoto = brandsImages[indexPath.row]
        
        let url = URL(string: brandsImages[indexPath.row])
        
        cell.BrandImageCell.loadImage(fromURL: url!, placeHolderImage: "photo")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LenImageCell {
            cell.layer.borderColor = UIColor.blue.cgColor
            cell.layer.borderWidth = 2.0
            cell.layer.cornerRadius = 2.0
            photoSelected = cell.urlPhoto
            
            let url = URL(string: cell.urlPhoto)!
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data!)
            
            if previousViewController != nil {
                previousViewController?.photoSelected = photoSelected
                previousViewController?.ImageSelected.image = image
            }
            
            if editPreviousController != nil {
                editPreviousController?.logoImage.image = image
                editPreviousController?.photoSelected = photoSelected
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LenImageCell {
            cell.layer.borderWidth = 0
        }
    }
}
