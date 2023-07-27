//
//  RegisterProductsViewController.swift
//  app_firebase
//
//  Created by user230281 on 12/3/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Photos
import FirebaseAuth

class RegisterProductsViewController: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
{

    @IBOutlet weak var inputNameProduct: UITextField!
    @IBOutlet weak var inputCodeProduct: UITextField!
    @IBOutlet weak var inputDescriptionProduct: UITextField!
    @IBOutlet weak var inputClassificationProduct: UITextField!
    @IBOutlet weak var inputBrandProduct: UITextField!
    @IBOutlet weak var switchAntProduct: UISwitch!
    @IBOutlet weak var switchFotProduct: UISwitch!
    @IBOutlet weak var inputDiameterProduct: UITextField!
    @IBOutlet weak var inputHeightProduct: UITextField!
    @IBOutlet weak var inputValueProduct: UITextField!
    @IBOutlet weak var lensMenuButton: UIButton!
    @IBOutlet weak var indiceMenuButton: UIButton!
    
    @IBOutlet weak var pickerAdition: UIPickerView!
    @IBOutlet weak var pickerEsf: UIPickerView!
    @IBOutlet weak var pickerCil: UIPickerView!
    @IBOutlet weak var pickerEsfMax: UIPickerView!
    @IBOutlet weak var pickerAditionMax: UIPickerView!
    
    @IBOutlet weak var brandTableView: UITableView!
    
    @IBOutlet weak var ImageSelected: LazyImageView!
    
    let menus = Menus()
    let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    var imagePickerController = UIImagePickerController()
    
    var brands: [String] = []
    var brandsTempArray: [String] = []
    var brandSearchArray: [String] = []
    
    var brandsImages: [String] = []
    
    var typeLente: String = ""
    var indiceLente: String = ""
    var photoSelected: String = ""
    
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var amt = 0
    
    var aditionValue = "0.25"
    var aditionValueMax = "4.0"
    var esfValue = "-30.00"
    var esfValueMax = "+30.00"
    var cilValue = "-30.00"
    
    let userID = Auth.auth().currentUser!.uid
    
    var modalImageController: ModalImageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBrands()
        
        imagePickerController.delegate = self
        
        brandTableView.delegate = self
        brandTableView.dataSource = self
        brandTableView.isHidden = true
        
        lensMenuButton.menu = menuTypesLens(sender: lensMenuButton)
        indiceMenuButton.menu = menuIndiceLens(sender: indiceMenuButton)
        
        inputDiameterProduct.delegate = self
        inputHeightProduct.delegate = self
        inputValueProduct.delegate = self
        
        inputValueProduct.tag = 1
        
        pickerAdition.delegate = self
        pickerAdition.dataSource = self
        pickerCil.delegate = self
        pickerCil.dataSource = self
        pickerEsf.delegate = self
        pickerEsf.dataSource = self
        pickerEsfMax.delegate = self
        pickerEsfMax.dataSource = self
        pickerAditionMax.delegate = self
        pickerAditionMax.dataSource = self
        
        pickerAdition.tag = 1
        pickerEsf.tag = 2
        pickerCil.tag = 3
        pickerEsfMax.tag = 4
        pickerAditionMax.tag = 5
        
        ImageSelected.image = UIImage(systemName: "photo")
    }
    
    func updateTextField() -> String? {
        let number = Double(amt/100) + Double(amt%100)/100
        return numberFormatter.string(from: NSNumber(value: number))
    }
    
    func loadBrands() {
        db.collection("users/\(userID)/lentes")
            .getDocuments{
                (querySnapshot, error) in
                self.brands = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.brands.append((data["marca"] as? String)!)
                }
                self.brands = Array(Set(self.brands))
                self.brandTableView.reloadData()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "modalImages" {
                if let modalVC = segue.destination as? ModalImageController {
                    modalVC.previousViewController = self
                }
            }
        }
    
    @IBAction func brandEditingDidBegin(_ sender: UITextField) {
        brandTableView.isHidden = false
        brandsTempArray = brands
    }
    
    @IBAction func brandEditingDidEnd(_ sender: Any) {
        brandTableView.isHidden = true
        brands = brandsTempArray
        brandTableView.reloadData()
    }
    
    @IBAction func brandEditingChanged(_ sender: UITextField) {
        brandTableView.isHidden = false
        brands = brandsTempArray
        filterBrands(searctText: inputBrandProduct.text!)
        brands = brandSearchArray
        brandTableView.reloadData()
        if sender.text == "" {
            brandTableView.isHidden = true
        }
    }
    
    func filterBrands(searctText: String) {
        brandSearchArray = brands.filter {
            item in return item.lowercased().contains(searctText.lowercased())
        }
    }
    
    @IBAction func uploadImageTapped(_ sender: Any){
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    func validatetextFields() -> Bool {
        let codeInput = inputCodeProduct.text != ""
        let nameInput = inputNameProduct.text != ""
        let descriptionInput = inputDescriptionProduct.text != ""
        let classificationInput = inputClassificationProduct.text != ""
        let brandInput = inputBrandProduct.text != ""
        let diameterInput = inputDiameterProduct.text != ""
        let heightInput = inputHeightProduct.text != ""
        let valueInput = inputValueProduct.text != ""
        let typeLensSelect =  typeLente != ""
        let indiceSelect = indiceLente != ""
        let validatePhoto = photoSelected != ""
        
        return codeInput && nameInput && descriptionInput &&
               classificationInput && brandInput &&
               diameterInput && heightInput && valueInput &&
               typeLensSelect && indiceSelect && validatePhoto
    }
    
    func sendData() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        var valueFrame = 0.0
        
        if let number = formatter.number(from: inputValueProduct.text!) {
            let amount = number.doubleValue
            valueFrame = amount
        }
        
        let collection = db.collection("users/\(userID)/lentes")
        
        collection.addDocument(data: [
                "code": inputCodeProduct.text ?? "",
                "nome": inputNameProduct.text ?? "",
                "descricao": inputDescriptionProduct.text ?? "",
                "classificacao": inputClassificationProduct.text ?? "",
                "marca": inputBrandProduct.text ?? "",
                "adicao_min": aditionValue,
                "adicao_max": aditionValueMax,
                "antirreflexo": switchAntProduct.isOn,
                "fotossensivel": switchFotProduct.isOn,
                "diametro": inputDiameterProduct.text ?? "",
                "esfera_min": esfValue,
                "esfera_max": esfValueMax,
                "cilindro": cilValue,
                "altura": inputHeightProduct.text ?? "",
                "valor": valueFrame,
                "tipo_lente": typeLente,
                "indice": indiceLente,
                "photo": photoSelected
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendDataToFirebase(_ sender: UIButton) {
        
        if validatetextFields() {
            sendData()
        } else {
            let alert = UIAlertController(title: "Preencha todos os campos obrigatórios",
                                          message: "",
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Fechar",
                                          style: UIAlertAction.Style.destructive,
                                          handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func menuTypesLens(sender: UIButton) -> UIMenu {
        let visaoSimples = UIAction(title: "Visão simples"){
            _ in
            sender.setTitle("Visão simples", for: .normal)
            self.typeLente = "Visão simples"
        }
        
        let bifocal = UIAction(title: "Bifocal"){
            _ in
            sender.setTitle("Bifocal", for: .normal)
            self.typeLente = "Bifocal"
        }
        
        let progressivo = UIAction(title: "Progressivo"){
            _ in
            sender.setTitle("Progressivo", for: .normal)
            self.typeLente = "Progressivo"
        }
        
        let lentePronta = UIAction(title: "Lente pronta"){
            _ in
            sender.setTitle("Lente pronta", for: .normal)
            self.typeLente = "Lente pronta"
        }
        
        let menu = UIMenu(
                    title: "Tipos de lentes",
                    children: [visaoSimples, bifocal, progressivo, lentePronta]
                    )
        
        sender.showsMenuAsPrimaryAction = true
        sender.menu = menu
        
        return menu
    }
    
    func menuIndiceLens(sender: UIButton) -> UIMenu {
        let value1 = UIAction(title: "1.49"){
            _ in
            sender.setTitle("1.49", for: .normal)
            self.indiceLente = "1.49"
        }
        
        let value2 = UIAction(title: "1.56"){
            _ in
            sender.setTitle("1.56", for: .normal)
            self.indiceLente = "1.56"
        }
        
        let value3 = UIAction(title: "1.59"){
            _ in
            sender.setTitle("1.59", for: .normal)
            self.indiceLente = "1.59"
        }
        
        let value4 = UIAction(title: "1.60"){
            _ in
            sender.setTitle("1.60", for: .normal)
            self.indiceLente = "1.60"
        }
        
        let value5 = UIAction(title: "1.67"){
            _ in
            sender.setTitle("1.67", for: .normal)
            self.indiceLente = "1.67"
        }
        
        let value6 = UIAction(title: "1.70"){
            _ in
            sender.setTitle("1.70", for: .normal)
            self.indiceLente = "1.70"
        }
        
        let value7 = UIAction(title: "1.74"){
            _ in
            sender.setTitle("1.74", for: .normal)
            self.indiceLente = "1.74"
        }
        
        let value8 = UIAction(title: "1.80"){
            _ in
            sender.setTitle("1.80", for: .normal)
            self.indiceLente = "1.80"
        }
        
        let value9 = UIAction(title: "1.90"){
            _ in
            sender.setTitle("1.90", for: .normal)
            self.indiceLente = "1.90"
        }
        
        let menu = UIMenu(
            title: "Indices",
            children: [
                value1, value2, value3,
                value4, value5, value6,
                value7, value8, value9
            ]
        )
        
        sender.showsMenuAsPrimaryAction = true
        sender.menu = menu
        
        return menu
    }
}

extension RegisterProductsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            if let digit = Int(string) {
                amt = amt * 10 + digit
                inputValueProduct.text = updateTextField()
            }
            
            if string == "" {
                amt = amt/10
                inputValueProduct.text = updateTextField()
            }
            
            return false
        }
        
        let allowedCharacters = "1234567890"
        let allowedCharactersSet = CharacterSet(charactersIn: allowedCharacters)
        let typesCharactersSet = CharacterSet(charactersIn: string)
        return allowedCharactersSet.isSuperset(of: typesCharactersSet)
    }
}

extension RegisterProductsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = brands[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputBrandProduct.text = brands[indexPath.row]
        brandTableView.isHidden = true
    }
    
}

extension RegisterProductsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return menus.generateAdition().count
        case 2:
            return menus.generateValuesDegree().count
        case 3:
            return menus.generateValuesDegree().count
        case 4:
            return menus.generateValuesDegree().count
        case 5:
            return menus.generateAdition().count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return String(menus.generateAdition()[row])
        case 2:
            return menus.generateValuesDegree()[row]
        case 3:
            return menus.generateValuesDegree()[row]
        case 4:
            return menus.generateValuesDegree()[row]
        case 5:
            return String(menus.generateAdition()[row])
        default:
            return "Data not found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            aditionValue = String(menus.generateAdition()[row])
        case 2:
            esfValue = menus.generateValuesDegree()[row]
        case 3:
            cilValue = menus.generateValuesDegree()[row]
        case 4:
            esfValueMax = menus.generateValuesDegree()[row]
        case 5:
            aditionValueMax = String(menus.generateAdition()[row])
        default:
            return
        }
    }
    
}
