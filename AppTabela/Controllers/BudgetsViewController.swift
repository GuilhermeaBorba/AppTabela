//
//  BudgetsViewController.swift
//  app_firebase
//
//  Created by user230281 on 11/25/22.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class BudgetsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var productPhoto: UIImageView!
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var indiceLabel: UILabel!
    @IBOutlet weak var antirreflexoLabel: UILabel!
    @IBOutlet weak var fotossensivelLabel: UILabel!
    @IBOutlet weak var adititionLabel: UILabel!
    @IBOutlet weak var esfLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var saveBudgetButton: UIButton!
    @IBOutlet weak var nameClient: UITextField!
    @IBOutlet weak var phoneClient: UITextField!
    @IBOutlet weak var emailClient: UITextField!
    @IBOutlet weak var frameClient: UITextField!
    @IBOutlet weak var valueFrameClient: UITextField!
    @IBOutlet weak var discountClient: UITextField!
    @IBOutlet weak var finalValue: UILabel!
    @IBOutlet weak var paymentMenu: UIButton!
    
    let menus = Menus()
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    var product: Product!
    var paymentMethod: String! = "a vista"
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    let format = DateFormatter()
    let date = Date()
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CADASTRAR ORÇAMENTO"
        
        valueFrameClient.delegate = self
        discountClient.delegate = self
        
        let url = URL(string: product.photo!)!
        
        let data = try? Data(contentsOf: url)
        
        self.productPhoto.image = UIImage(data: data!)
        
        codeLabel.text = "CÓD: \(product.code!)"
        productNameLabel.text = product.nome!
        classificationLabel.text = "Classificação: \(product.classificacao!)"
        typeLabel.text = "Tipo: \(product.tipoLente!)"
        brandName.text = "Marca: \(product.marca!)"
        indiceLabel.text = "Índice: \(product.indice!)"
        antirreflexoLabel.text = "Antirreflexo: \(product.antirreflexo ? "SIM" : "NÃO")"
        fotossensivelLabel.text = "Fotossensível: \(product.fotossensivel ? "SIM" : "NÃO")"
        adititionLabel.text = "Adição: \(product.adicao_min!) a \(product.adicao_max!)"
        esfLabel.text = "ESF: \(product.esfera_min!) a \(product.esfera_max!)"
        diameterLabel.text = "Diametro: \(product.diametro!)"
        heightLabel.text = "Altura da montagem: \(product.height!)"
        valueLabel.text = self.formatCurrentNumber(current: product.value!)
        
        format.dateStyle = .medium
        format.timeStyle = .medium
        format.dateFormat = "dd-MM-yyyy"
        
        saveBudgetButton.layer.cornerRadius = 8
        saveBudgetButton.layer.cornerCurve = .continuous
        saveBudgetButton.contentEdgeInsets = UIEdgeInsets(
            top: 10,
            left: 20,
            bottom: 10,
            right: 20
        )
        
        finalValue.text = self.formatCurrentNumber(current: product.value!)
        paymentMenu.menu = paymentMethodsMenu(sender: paymentMenu)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = "1234567890"
        let allowedCharactersSet = CharacterSet(charactersIn: allowedCharacters)
        let typesCharactersSet = CharacterSet(charactersIn: string)
        return allowedCharactersSet.isSuperset(of: typesCharactersSet)
    }
    
    func loadImage() {
        storage.child("images/\(userID)/\(product.code!)")
            .downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    self.productPhoto.image = UIImage(systemName: "photo")
                    return
                }
                
                let urlString = URL(string: url.absoluteString)
                let data = try? Data(contentsOf: urlString!)
                self.productPhoto.image = UIImage(data: data!)
                
            })
    }
    
    func navigateToListBudget() {
        if let tableBudgets = self.storyboard?.instantiateViewController(withIdentifier: "TableBudgets") as? BudgetsListViewController {
            self.navigationController?.pushViewController(tableBudgets, animated: true)
        }
    }
    
    func sendDataBudget() {
        let collection: CollectionReference = db.collection("users/\(userID)/orcamentos")
        
        let total = (product.value ?? 0) - (Double(discountClient.text!) ?? 0) + (Double(valueFrameClient.text!) ?? 0)
        
        collection.addDocument(data: [
            "cliente": nameClient.text ?? "",
            "telefone": phoneClient.text ?? "",
            "email": emailClient.text ?? "",
            "armacao": frameClient.text ?? "",
            "valor_armacao": Double(valueFrameClient.text!) ?? 0,
            "desconto": Double(discountClient.text!) ?? 0,
            "total": total,
            "forma_pagamento": paymentMethod ?? "",
            "id_lente": product.documentId,
            "data": format.string(from: date)
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
            
            self.navigateToListBudget()
        }
        
    }
    
    
    @IBAction func sendData(_ sender: Any) {
        sendDataBudget()
    }
    
    
    func paymentMethodsMenu(sender: UIButton) -> UIMenu {
        let vista = UIAction(title: "À vista"){
            _ in
            sender.setTitle("À vista", for: .normal)
            self.paymentMethod = "a vista"
        }
        
        let cartao = UIAction(title: "Cartão de crédito"){
            _ in
            sender.setTitle("Cartão de crédito", for: .normal)
            self.paymentMethod = "cartao de credito"
        }
        
        let menu = UIMenu(
            title: "Métodos de pagamento",
            children: [vista, cartao]
        )
        
        sender.showsMenuAsPrimaryAction = true
        sender.menu = menu
        
        return menu
    }
    
    @IBAction func changeValueFrame(_ sender: UITextField) {
        let value = (product.value ?? 0) - (Double(discountClient.text!) ?? 0) + (Double(valueFrameClient.text!) ?? 0)
        self.finalValue.text = self.formatCurrentNumber(current: value)
    }
    
    @IBAction func changeDiscountVaue(_ sender: UITextField) {
        let value = (product.value ?? 0) - (Double(discountClient.text!) ?? 0) + (Double(valueFrameClient.text!) ?? 0)
        self.finalValue.text = self.formatCurrentNumber(current: value)
    }
    
}
