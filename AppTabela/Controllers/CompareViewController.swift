//
//  CompareViewController.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 23/12/22.
//

import UIKit

class CompareViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var product1: UILabel?
    @IBOutlet weak var product2: UILabel?
    @IBOutlet weak var product3: UILabel?
    
    @IBOutlet weak var lenValue1: UILabel!
    @IBOutlet weak var lenValue2: UILabel!
    @IBOutlet weak var lenValue3: UILabel!
    
    var products: [Product]!
    var images: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image1.image = loadImageProduct(url: products[0].photo!)
        image2.image = loadImageProduct(url: products[1].photo!)
        image3.image = loadImageProduct(url: products[2].photo!)
        
        product1?.text = products[0].nome
        product2?.text = products[1].nome
        product3?.text = products[2].nome
        
        lenValue1.text = formatToCurrent(value: products[0].value!)
        lenValue2.text = formatToCurrent(value: products[1].value!)
        lenValue3.text = formatToCurrent(value: products[2].value!)
        
        print(products)
        
    }
    
    func formatToCurrent(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        let formatedAmount = formatter.string(from: value as NSNumber)
        
        return formatedAmount!
    }
    
    func loadImageProduct(url: String) -> UIImage {
        let urlString = URL(string: url)!
        
        let data = try? Data(contentsOf: urlString)
        
        let image = UIImage(data: data!)
        
        if let img = image {
            return img
        } else {
            return UIImage(systemName: "photo")!
        }
    }
   
    
    @IBAction func createBudgetOne(_ sender: UIButton) {
        if let createBudgetVC = self.storyboard?.instantiateViewController(withIdentifier: "createBudget") as? BudgetsViewController {
            createBudgetVC.product = products[0]
            self.navigationController?.pushViewController(createBudgetVC, animated: true)
        }
    }
    
    @IBAction func createBudgetTwo(_ sender: Any) {
        if let createBudgetVC = self.storyboard?.instantiateViewController(withIdentifier: "createBudget") as? BudgetsViewController {
            createBudgetVC.product = products[1]
            self.navigationController?.pushViewController(createBudgetVC, animated: true)
        }
    }
    
    @IBAction func createBudgetThree(_ sender: Any) {
        if let createBudgetVC = self.storyboard?.instantiateViewController(withIdentifier: "createBudget") as? BudgetsViewController {
            createBudgetVC.product = products[2]
            self.navigationController?.pushViewController(createBudgetVC, animated: true)
        }
    }
    
    
}
