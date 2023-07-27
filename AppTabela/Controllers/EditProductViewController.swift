//
//  EditProductViewController.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 16/12/22.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Photos

class EditProductViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editCode: UITextField!
    @IBOutlet weak var editDescription: UITextField!
    @IBOutlet weak var editClassification: UITextField!
    @IBOutlet weak var editBrand: UITextField!
    @IBOutlet weak var editAnt: UISwitch!
    @IBOutlet weak var editFot: UISwitch!
    @IBOutlet weak var editDiameter: UITextField!
    @IBOutlet weak var editHeight: UITextField!
    @IBOutlet weak var editValue: UITextField!
    
    @IBOutlet weak var menuTypeLens: UIButton!
    @IBOutlet weak var menuIndiceLens: UIButton!
    @IBOutlet weak var pickerAdition: UIPickerView!
    
    @IBOutlet weak var pickerEsf: UIPickerView!
    @IBOutlet weak var pickerCil: UIPickerView!
    @IBOutlet weak var pickerEsfMax: UIPickerView!
    @IBOutlet weak var pickerAditionMax: UIPickerView!
    
    @IBOutlet weak var editBrandTableView: UITableView!
    @IBOutlet weak var logoImage: LazyImageView!
    
    let menus = Menus()
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    var imagePickerController = UIImagePickerController()
    
    var brands: [String] = []
    var brandsTempArray: [String] = []
    var brandSearchArray: [String] = []
    
    var brandsImages: [String] = []
    
    var typeLen: String!
    var indiceLen: String!
    var documentId: String!
    var product: Product!
    var aditionValue: String!
    var aditionValueMax: String!
    var esfValue: String!
    var esfValueMax: String!
    var cilValue: String!
    var imageFinalUrl: String?
    var photoSelected: String!
    
    var loading: UIAlertController?
    
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var amt = 0
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLayoutSubviews() {
        super.viewDidLoad()
        loadBrands()
        
        let urlImage = URL(string: product.photo!)
        
        logoImage.loadImage(fromURL: urlImage!, placeHolderImage: "photo")
        
        imagePickerController.delegate = self
        pickerAdition.delegate = self
        pickerEsf.delegate = self
        pickerCil.delegate = self
        pickerEsfMax.delegate = self
        pickerAditionMax.delegate = self
        
        editDiameter.delegate = self
        editHeight.delegate = self
        editValue.delegate = self
        
        editValue.tag = 1
        
        editBrandTableView.delegate = self
        editBrandTableView.dataSource = self
        editBrandTableView.isHidden = true
        
        pickerAdition.tag = 1
        pickerEsf.tag = 2
        pickerCil.tag = 3
        pickerEsfMax.tag = 4
        pickerAditionMax.tag = 5
        
        editName.text = product.nome
        editCode.text = product.code
        editClassification.text = product.classificacao
        editBrand.text = product.marca
        editAnt.isOn = product.antirreflexo
        editFot.isOn = product.fotossensivel
        editDiameter.text = product.diametro
        editHeight.text = product.height
        editValue.text = self.formatCurrentNumber(current: product.value!)
        editDescription.text = product.descricao
        photoSelected = product.photo
        
        typeLen = product.tipoLente
        indiceLen = product.indice
        
        menuIndiceLens.menu = menuIndiceLens(sender: menuIndiceLens)
        menuTypeLens.menu = menuLens(sender: menuTypeLens)
        
        menuTypeLens.setTitle(product.tipoLente, for: .normal)
        menuIndiceLens.setTitle(product.indice, for: .normal)
        
        aditionValue = product.adicao_min!
        aditionValueMax = product.adicao_max!
        esfValue = product.esfera_min!
        esfValueMax = product.esfera_max!
        cilValue = product.cilindro!
        
        pickerAdition.selectRow(indexProductEditAdition(value: product.adicao_min!), inComponent: 0, animated: true)
        pickerEsf.selectRow(indexProductEditValueDegree(value: product.esfera_min!), inComponent: 0, animated: true)
        pickerCil.selectRow(indexProductEditValueDegree(value: product.cilindro!), inComponent: 0, animated: true)
        
        pickerAditionMax.selectRow(indexProductEditAdition(value: product.adicao_max!), inComponent: 0, animated: true)
        pickerEsfMax.selectRow(indexProductEditValueDegree(value: product.esfera_max!), inComponent: 0, animated: true)
        
        self.title = "EDITAR PRODUTO"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "editModalImage" {
                if let modalVC = segue.destination as? ModalImageController {
                    modalVC.editPreviousController = self
                }
            }
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
                self.editBrandTableView.reloadData()
            }
    }
    
    @IBAction func editBrandEditingDidBegin(_ sender: UITextField) {
        editBrandTableView.isHidden = false
        brandsTempArray = brands
    }
    
    @IBAction func editBrandEditingDidEnd(_ sender: UITextField) {
        editBrandTableView.isHidden = true
        brands = brandsTempArray
        editBrandTableView.reloadData()
    }
    
    @IBAction func editBrandEditingDidChanged(_ sender: UITextField) {
        editBrandTableView.isHidden = false
        brands = brandsTempArray
        filterBrands(searctText: editBrand.text!)
        brands = brandSearchArray
        editBrandTableView.reloadData()
        if sender.text == "" {
            editBrandTableView.isHidden = true
        }
    }
    
    func filterBrands(searctText: String) {
        brandSearchArray = brands.filter {
            item in return item.lowercased().contains(searctText.lowercased())
        }
    }
    
    private func indexProductEditValueDegree(value: String) -> Int {
        let degrees = menus.generateValuesDegree()
        
        if let index = degrees.firstIndex(of: value) {
            return index
        }
        
        return 1
    }
    
    private func indexProductEditAdition(value: String) -> Int {
        let aditions = menus.generateAdition().map { $0 }
        
        if let index = aditions.firstIndex(of: value) {
            return index
        }
        
        return 1
    }
    
    func validatetextFields() -> Bool {
        let nameInput = editName.text != ""
        let descriptionInput = editDescription.text != ""
        let classificationInput = editClassification.text != ""
        let brandInput = editBrand.text != ""
        let diameterInput = editDiameter.text != ""
        let heightInput = editHeight.text != ""
        let valueInput = editValue.text != ""
        let typeLensSelect =  typeLen != ""
        let indiceSelect = indiceLen != ""
        
        return nameInput && descriptionInput &&
               classificationInput && brandInput &&
               diameterInput && heightInput && valueInput && typeLensSelect && indiceSelect
    }
    
    func updateData() -> Void {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        var valueFrame = 0.0
        
        if let number = formatter.number(from: editValue.text!) {
            let amount = number.doubleValue
            valueFrame = amount
        }
        
        let collection = db.collection("users/\(userID)/lentes")
        
        do {
            collection.document(documentId).updateData([
                "code": editCode.text ?? "",
                "nome": editName.text ?? "",
                "descricao": editDescription.text ?? "",
                "classificacao": editClassification.text ?? "",
                "marca": editBrand.text ?? "",
                "adicao_min": aditionValue!,
                "adicao_max": aditionValueMax!,
                "antirreflexo": editAnt.isOn,
                "fotossensivel": editFot.isOn,
                "diametro": editDiameter.text ?? "",
                "esfera_min": esfValue!,
                "esfera_max": esfValueMax!,
                "cilindro": cilValue!,
                "altura": editHeight.text ?? "",
                "valor": valueFrame,
                "tipo_lente": typeLen!,
                "indice": indiceLen!,
                "photo": photoSelected!,
            ], completion: nil)
        }
    }
    

    
    @IBAction func editProductData(_ sender: UIButton){
        //loading = self.loader(message: "Atualizando dados")
        
        let validInputs = validatetextFields()
                
        if validInputs {
            
            updateData()
            
            //stopLoader(loader: self.loading!)
            
            self.navigationController?.popViewController(animated: true)
            
        } else {
            self.stopLoader(loader: self.loading!)
                
            let alert = UIAlertController(title: "Preencha todos os campos obrigatórios",
                                          message: "",
                                          preferredStyle: UIAlertController.Style.alert)
                    
            alert.addAction(UIAlertAction(title: "Fechar",
                                          style: UIAlertAction.Style.destructive,
                                          handler: nil))
                    
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func menuLens(sender: UIButton) -> UIMenu {
        let visaoSimples = UIAction(title: "Visão simples"){
            _ in
            sender.setTitle("Visão simples", for: .normal)
            self.typeLen = "Visão simples"
        }
        
        let bifocal = UIAction(title: "Bifocal"){
            _ in
            sender.setTitle("Bifocal", for: .normal)
            self.typeLen = "Bifocal"
        }
        
        let progressivo = UIAction(title: "Progressivo"){
            _ in
            sender.setTitle("Progressivo", for: .normal)
            self.typeLen = "Progressivo"
        }
        
        let lentePronta = UIAction(title: "Lente pronta"){
            _ in
            sender.setTitle("Lente pronta", for: .normal)
            self.typeLen = "Lente pronta"
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
            self.indiceLen = "1.49"
        }
        
        let value2 = UIAction(title: "1.56"){
            _ in
            sender.setTitle("1.56", for: .normal)
            self.indiceLen = "1.56"
        }
        
        let value3 = UIAction(title: "1.59"){
            _ in
            sender.setTitle("1.59", for: .normal)
            self.indiceLen = "1.59"
        }
        
        let value4 = UIAction(title: "1.60"){
            _ in
            sender.setTitle("1.60", for: .normal)
            self.indiceLen = "1.60"
        }
        
        let value5 = UIAction(title: "1.67"){
            _ in
            sender.setTitle("1.67", for: .normal)
            self.indiceLen = "1.67"
        }
        
        let value6 = UIAction(title: "1.70"){
            _ in
            sender.setTitle("1.70", for: .normal)
            self.indiceLen = "1.70"
        }
        
        let value7 = UIAction(title: "1.74"){
            _ in
            sender.setTitle("1.74", for: .normal)
            self.indiceLen = "1.74"
        }
        
        let value8 = UIAction(title: "1.80"){
            _ in
            sender.setTitle("1.80", for: .normal)
            self.indiceLen = "1.80"
        }
        
        let value9 = UIAction(title: "1.90"){
            _ in
            sender.setTitle("1.90", for: .normal)
            self.indiceLen = "1.90"
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

extension EditProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
        cell.textLabel?.text = brands[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editBrand.text = brands[indexPath.row]
        editBrandTableView.isHidden = true
    }
}

extension EditProductViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            if let digit = Int(string) {
                amt = amt * 10 + digit
                editValue.text = updateTextField()
            }
            
            if string == "" {
                amt = amt/10
                editValue.text = updateTextField()
            }
            
            return false
        }
        
        let allowedCharacters = "1234567890"
        let allowedCharactersSet = CharacterSet(charactersIn: allowedCharacters)
        let typesCharactersSet = CharacterSet(charactersIn: string)
        return allowedCharactersSet.isSuperset(of: typesCharactersSet)
    }
}

extension EditProductViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
