import UIKit
import FirebaseFirestore
import FirebaseAuth

class AdvancedFilterViewController: UIViewController {
    
    @IBOutlet weak var switchFotossensivel: UISwitch!
    @IBOutlet weak var sliderValue: UISlider!
    @IBOutlet weak var switchAntirreflexo: UISwitch!
    @IBOutlet weak var sliderAdicao: UISlider!
    @IBOutlet weak var buttonShowResults: UIButton!
    @IBOutlet weak var buttonMenuClassification: UIButton!
    @IBOutlet weak var buttonIndiceRefracao: UIButton!
    @IBOutlet weak var buttonTypeLens: UIButton!
    @IBOutlet weak var buttonMenuBrand: UIButton!
    @IBOutlet weak var buttonCleanFilter: UIBarButtonItem!
    @IBOutlet weak var aditionMaxValue: UILabel!
    @IBOutlet weak var maxValue: UILabel!
    @IBOutlet weak var maxEsfValue: UILabel!
    @IBOutlet weak var sliderEsf: UISlider!
    @IBOutlet weak var maxCilValue: UILabel!
    @IBOutlet weak var sliderCil: UISlider!
    
    let menus = Menus()
    let db = Firestore.firestore()
    var products: [Product] = []
    
    var brands: [String?] = []
    var actionsbrands: [UIAction] = []
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonTypeLens.menu = menus.MenuTypeLens(sender: buttonTypeLens)
        buttonIndiceRefracao.menu = menus.MenuIndices(sender: buttonIndiceRefracao)
        buttonMenuClassification.menu = menus.MenuClassifications(sender: buttonMenuClassification)
        
        loadBrands()
    }
    
    func loadBrands() {
        db.collection("users/\(userID)/lentes")
            .getDocuments{
                (querySnapshot, error) in
                self.brands = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.brands.append(data["marca"] as? String)
                }
                
                self.brands = Array(Set(self.brands))
                
                self.brands.forEach {
                    let str = $0
                    
                    self.actionsbrands.append(UIAction(title: str!) {
                        _ in
                        self.buttonMenuBrand.setTitle(str!, for: .normal)
                    })
                }
                
                self.buttonMenuBrand.menu = UIMenu(title: "Marcas", children: self.actionsbrands)
                
            }
    }
    
    func getProducts() async -> [Product] {
        let docRef = db.collection("users/\(userID)/lentes")
        
        var returnProducts: [Product] = []
        
        do {
            let data = try await docRef.getDocuments()
            
            let prods = data.documents.map { p in
                
                let product = Product(
                    documentId: p.documentID,
                    descricao: p["descricao"] as? String,
                    code: p["code"] as? String,
                    nome: p["nome"] as? String,
                    value:  p["valor"] as? Double,
                    classificacao: p["classificacao"] as? String,
                    marca: p["marca"] as? String,
                    adicao_min: p["adicao_min"] as? String,
                    adicao_max: p["adicao_max"] as? String,
                    antirreflexo: p["antirreflexo"] as? Bool,
                    fotossensivel: p["fotossensivel"] as? Bool,
                    diametro: p["diametro"] as? String,
                    esfera_min: p["esfera_min"] as? String,
                    esfera_max: p["esfera_max"] as? String,
                    cilindro: p["cilindro"] as? String,
                    height: p["altura"] as? String,
                    tipoLente: p["tipo_lente"] as? String,
                    indice: p["indice"] as? String,
                    photo: p["photo"] as? String
                )
                
                return product
                
            }
            
            returnProducts = prods
            
        }
        catch {
            print(error)
        }
           
        return returnProducts
        
    }
    
    func filteringProducts(filterProducts: [Product]) async -> [Product] {
        let filteredProducts = filterProducts.filter({
            (p: Product) -> Bool in
            
            if buttonMenuClassification.titleLabel?.text! == "Todas" &&
                buttonTypeLens.titleLabel?.text! == "Todas" &&
                buttonIndiceRefracao.titleLabel?.text! == "Todas" &&
                switchAntirreflexo.isOn &&
                switchFotossensivel.isOn &&
                sliderAdicao.value == sliderAdicao.maximumValue &&
                sliderEsf.value == sliderEsf.maximumValue &&
                sliderCil.value == sliderCil.maximumValue &&
                Double(sliderValue.value) == Double(sliderValue.maximumValue)
            {
                return true
            }
            
            let classificationFilter: Bool = buttonMenuClassification.titleLabel?.text! == "Todas" ? p.classificacao != "" : p.classificacao == buttonMenuClassification.titleLabel?.text!
            let lensFilter: Bool = buttonTypeLens.titleLabel?.text! == "Todas" ? p.tipoLente != "" : p.tipoLente?.lowercased() == buttonTypeLens.titleLabel?.text!.lowercased()
            let brandFilter: Bool = buttonMenuBrand.titleLabel?.text! == "Todas" ? p.marca != "" : p.marca == buttonMenuBrand.titleLabel?.text!
            let indiceFilter: Bool = buttonIndiceRefracao.titleLabel?.text! == "Todas" ? p.indice != "" : p.indice == buttonIndiceRefracao.titleLabel?.text!
            let antirreflexoFilter: Bool = p.antirreflexo == switchAntirreflexo.isOn
            let fotossensivelFilter: Bool = p.fotossensivel == switchFotossensivel.isOn
            var adicaoFilter: Bool = Double(p.adicao_min ?? "0") ?? 0 <= Double(sliderAdicao.value) && Double(p.adicao_max ?? "0") ?? 0 >= Double(sliderAdicao.value)
            let valueFilter: Bool = p.value! <= Double(sliderValue.value)
            let esfericoFilter: Bool = Double(p.esfera_min ?? "0") ?? 0 <= Double(sliderEsf.value) && Double(p.esfera_max ?? "0") ?? 0 >= Double(sliderEsf.value)
            let cilindricoFilter: Bool = Double(p.cilindro ?? "0") ?? 0 >= Double(sliderCil.value)
            
            if buttonTypeLens.titleLabel?.text! == "Visão simples" ||
               buttonTypeLens.titleLabel?.text! == "Lente pronta" {
                adicaoFilter = true
            }
            
            return lensFilter && classificationFilter && brandFilter && indiceFilter && antirreflexoFilter && fotossensivelFilter && valueFilter && adicaoFilter && esfericoFilter && valueFilter && cilindricoFilter
        })
        
        return filteredProducts
    }
    
    @IBAction func filteringData(_ sender: UIButton) {
        Task { @MainActor in
            do {
                let allProducts = await getProducts()
                
                let filterProducts = await filteringProducts(filterProducts: allProducts)
                
                if filterProducts.isEmpty {
                    let alert = UIAlertController(title: "Nenhum produto encontrado!",
                                                  message: "Nenhum produto cadastrado com essas informações",
                                                  preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "Fechar",
                                                  style: UIAlertAction.Style.cancel,
                                                  handler: nil))

                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let mainVc = self.storyboard?.instantiateViewController(withIdentifier: "main") as? MainViewController {
                        mainVc.filterProducts = filterProducts
                        mainVc.products = filterProducts
                        mainVc.reloadTable = false
                        mainVc.title = "LENTES FILTRADAS"
                        mainVc.navigationItem.setRightBarButtonItems(nil, animated: false)
                        self.navigationController?.pushViewController(mainVc, animated: true)
                    }
                }
                
            }
        }
    }
    
    @IBAction func cleanFilter(_ sender: UIButton) {
        buttonMenuClassification.setTitle("Todas", for: .normal)
        buttonTypeLens.setTitle("Todas", for: .normal)
        buttonMenuBrand.setTitle("Todas", for: .normal)
        buttonIndiceRefracao.setTitle("Todas", for: .normal)
    }
    
    @IBAction func changeAditionValue(_ sender: UISlider) {
        let step: Float = 0.25
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        aditionMaxValue.text = String(format: "%.2f", sliderAdicao.value)
    }
    
    @IBAction func changeValue(_ sender: UISlider) {
        let step: Float = 100
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        maxValue.text = self.formatCurrentNumber(current: Double(sliderValue.value))
    }
    
    @IBAction func changeEsfValue(_ sender: UISlider) {
        let step: Float = 0.25
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        maxEsfValue.text = String(format: "%.2f", Double(sliderEsf.value))
    }
    
    @IBAction func changeCilValue(_ sender: UISlider) {
        let step: Float = 0.25
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        maxCilValue.text = String(format: "%.2f", sliderCil.value)
    }
    
}

