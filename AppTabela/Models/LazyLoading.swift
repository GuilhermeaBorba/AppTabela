//
//  LazyLoading.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 14/01/23.
//

import Foundation
import UIKit

class LazyImageView: UIImageView {
    
    private let imageCache = NSCache<AnyObject, UIImage>()
    private var currentURL: URL?
    
    func loadImage(fromURL imageURL: URL, placeHolderImage: String) {
        self.currentURL = imageURL
        self.image = UIImage(named: placeHolderImage)
        
        if let cachedImage = self.imageCache.object(forKey: imageURL as AnyObject) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, _, _) in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  self.currentURL == imageURL else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageCache.setObject(image, forKey: imageURL as AnyObject)
                self.image = image
            }
        }.resume()
    }
}


