//
//  EditBudgetViewController.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 23/12/22.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class EditBudgetViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var codeProduct: UILabel!
    @IBOutlet weak var nameProduct: UILabel!
    @IBOutlet weak var classificationProduct: UILabel!
    @IBOutlet weak var typeLensProduct: UILabel!
    @IBOutlet weak var brandProduct: UILabel!
    @IBOutlet weak var indiceProduct: UILabel!
    @IBOutlet weak var antirreflexoProduct: UILabel!
    @IBOutlet weak var fotossensivelProduct: UILabel!
    @IBOutlet weak var aditionProduct: UILabel!
    @IBOutlet weak var esfProduct: UILabel!
    @IBOutlet weak var diameterProduct: UILabel!
    @IBOutlet weak var heightProduct: UILabel!
    @IBOutlet weak var valueProduct: UILabel!
    
    @IBOutlet weak var editClientName: UITextField!
    @IBOutlet weak var editPhoneClient: UITextField!
    @IBOutlet weak var editEmailClient: UITextField!
    @IBOutlet weak var editFrameClient: UITextField!
    @IBOutlet weak var editValueFrame: UITextField!
    @IBOutlet weak var editDiscountClient: UITextField!
    @IBOutlet weak var editPaymentMethod: UIButton!
    @IBOutlet weak var finalValue: UILabel!
    
    let menus = Menus()
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    var product: Product!
    var budget: Budget!
    var documentId: String!
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "EDITAR ORÇAMENTO"
        
        editValueFrame.delegate = self
        editDiscountClient.delegate = self
        
        let url = URL(string: product.photo!)!
        
        let data = try? Data(contentsOf: url)
        
        self.imageProduct.image = UIImage(data: data!)
        
        codeProduct.text = "COD: \(product.code!)"
        nameProduct.text = product.nome
        classificationProduct.text = "CLASSIFICAÇÃO: \(product.classificacao!)"
        typeLensProduct.text = "TIPO: \(product.tipoLente!)"
        brandProduct.text = "MARCA: \(product.marca!)"
        indiceProduct.text = "ÍNDICE: \(product.indice!)"
        antirreflexoProduct.text = "ANTIRREFLEXO: \(product.antirreflexo ? "SIM" : "NÃo")"
        fotossensivelProduct.text = "FOTOSSENSÍVEL: \(product.fotossensivel ? "SIM" : "NÃO")"
        aditionProduct.text = "ADIÇÃO: \(product.adicao_min!) a \(product.adicao_max!)"
        esfProduct.text = "ESF: \(product.esfera_min!) a \(product.esfera_max!)"
        diameterProduct.text = "DIÂMETRO: \(product.diametro!)"
        heightProduct.text = "ALTURA DA MONTAGEM: \(product.height!)"
        valueProduct.text = self.formatCurrentNumber(current: product.value!)
        
        finalValue.text = self.formatCurrentNumber(current: budget.total!)
        
        editClientName.text = budget.client
        editPhoneClient.text = budget.phone
        editEmailClient.text = budget.email
        editFrameClient.text = budget.frame
        editValueFrame.text = String(Int(budget.frameVale!))
        editDiscountClient.text = String(Int(budget.discount!))
        editPaymentMethod.setTitle(budget.paymentForm, for: .normal)
        
        editPaymentMethod.menu = menus.MenuPaymentMehod(sender: editPaymentMethod)
        
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
                    self.imageProduct.image = UIImage(systemName: "photo")
                    return
                }
                
                let urlString = URL(string: url.absoluteString)
                let data = try? Data(contentsOf: urlString!)
                self.imageProduct.image = UIImage(data: data!)
                
            })
    }
    
    @IBAction func updateBudget(_ sender: UIButton) {
        let collection = db.collection("users/\(userID)/orcamentos")
        
        let total = (product.value ?? 0) - (Double(editDiscountClient.text!) ?? 0) + (Double(editValueFrame.text!) ?? 0)
        
        collection.document(documentId).updateData(
            [
                "cliente": editClientName.text ?? "",
                "telefone": editPhoneClient.text ?? "",
                "email": editEmailClient.text ?? "",
                "armacao": editFrameClient.text ?? "",
                "valor_armacao": Double(editValueFrame.text!) ?? 0,
                "desconto": Double(editDiscountClient.text!) ?? 0,
                "total": total,
                "forma_pagamento": editPaymentMethod.titleLabel?.text ?? ""
            ]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
                
                self.navigationController?.popViewController(animated: false)
            }
        
    }
    
    @IBAction func changeFrameEditValue(_ sender: UITextField) {
        let value = (product.value ?? 0) - (Double(editDiscountClient.text!) ?? 0) + (Double(editValueFrame.text!) ?? 0)
    
        finalValue.text = self.formatCurrentNumber(current: value)
    }
    
    
    @IBAction func changeDiscountEditValue(_ sender: UITextField) {
        let value = (product.value ?? 0) - (Double(editDiscountClient.text!) ?? 0) + (Double(editValueFrame.text!) ?? 0)
        
        finalValue.text = self.formatCurrentNumber(current: value)
    }
    

}
