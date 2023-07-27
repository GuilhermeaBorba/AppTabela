//
//  VCExtension.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 17/01/23.
//

import Foundation
import UIKit

extension UIViewController {
    public func loader(message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.style = .large
        alert.view.addSubview(indicator)
        self.parent?.present(alert, animated: true, completion: nil)
        return alert
    }
    
    public func stopLoader(loader: UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
    
    public func formatCurrentNumber(current: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        let formatedAmount = formatter.string(from: current as NSNumber)
        
        return formatedAmount!
    }
    
}
