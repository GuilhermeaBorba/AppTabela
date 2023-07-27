//
//  AdvancedFilterBudgetsViewController.swift
//  app_firebase
//
//  Created by user230281 on 11/25/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AdvancedFilterBudgetsViewController: UIViewController {
    
    @IBOutlet weak var brandMenu: UIButton!
    @IBOutlet weak var indiceMenu: UIButton!
    @IBOutlet weak var antirreflexoSwitch: UISwitch!
    @IBOutlet weak var fotossensivelSwitch: UISwitch!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var maxValue: UILabel!
    
    let menus = Menus()
    let db = Firestore.firestore()
    var budgets: [Budget] = []
    
    var brands: [String?] = []
    var actionsbrands: [UIAction] = []
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "APAGAR FILTROS", style: .plain, target: self, action: #selector(cleanFilters))
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.systemPink
        
        indiceMenu.menu = menus.MenuIndices(sender: indiceMenu)
        
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
                        self.brandMenu.setTitle(str!, for: .normal)
                    })
                }
                
                self.brandMenu.menu = UIMenu(title: "Marcas", children: self.actionsbrands)
                
            }
    }
    
    func getLenForId(budgetId: String) async -> Product? {
        let docRef = db.collection("users/\(userID)/lentes")
        var product: Product?
        
        do {
            let docLen = try await docRef.document(budgetId).getDocument()
            
            let data = docLen.data()
            
            product = Product(
                documentId: docLen.documentID,
                descricao: data!["descricao"] as? String,
                code: data!["code"] as? String,
                nome: data!["nome"] as? String,
                value:  data!["valor"] as? Double,
                classificacao: data!["classificacao"] as? String,
                marca: data!["marca"] as? String,
                adicao_min: data!["adicao_min"] as? String,
                adicao_max: data!["adicao_max"] as? String,
                antirreflexo: data!["antirreflexo"] as? Bool,
                fotossensivel: data!["fotossensivel"] as? Bool,
                diametro: data!["diametro"] as? String,
                esfera_min: data!["esfera_min"] as? String,
                esfera_max: data!["esfera_max"] as? String,
                cilindro: data!["cilindro"] as? String,
                height: data!["altura"] as? String,
                tipoLente: data!["tipo_lente"] as? String,
                indice: data!["indice"] as? String,
                photo: data!["photo"] as? String
            )
            
        }
        catch {
            print(error)
        }
        
        return product
    }
    
    func getBudgets() async -> [Budget] {
        let docRef = db.collection("users/\(userID)/orcamentos")
        
        var returnBudgets: [Budget] = []
        
        do {
            let data = try await docRef.getDocuments()
            
            let buds = data.documents.map { b in
            
                let budget = Budget(
                    documentId: b.documentID,
                    client: b["cliente"] as? String,
                    phone: b["telefone"] as? String,
                    email: b["email"] as? String,
                    frame: b["armacao"] as? String,
                    frameVale: b["valor_armacao"] as? Double,
                    discount: b["desconto"] as? Double,
                    total: b["total"] as? Double,
                    paymentForm: b["forma_pagamento"] as? String,
                    lensId: b["id_lente"] as! String,
                    data: b["data"] as? String,
                    len: nil
                )
                
                return budget
            }
            
            returnBudgets = buds
            
        }
        catch {
            print("Error")
        }
        
        return returnBudgets
        
    }
    
    func loadLensInBudgets(budgetsList: [Budget]) async -> [Budget] {
        var copyBudgetList = budgetsList
        var budgetsWithLens: [Budget] = []
        
        var i = 0
        
        for (index, b) in copyBudgetList.enumerated() {
            let len = await getLenForId(budgetId: b.lensId)
            
            await copyBudgetList[index].defineLen(product: len!)
            
            i += 1
        }
        
        budgetsWithLens = copyBudgetList
        
        return budgetsWithLens
    }
    
    func filteringBudgets(budgetsList: [Budget]) async -> [Budget] {
        let filterBudgtes = budgetsList.filter({
            (b: Budget) -> Bool in
            
            let brandFilter = brandMenu.titleLabel?.text == "Todas" ? b.len?.marca != "" : b.len?.marca == brandMenu.titleLabel?.text
            let indiceFilter = indiceMenu.titleLabel?.text == "Todas" ? b.len?.indice != "" : b.len?.indice == indiceMenu.titleLabel?.text
            let antirreflexoFilter = b.len?.antirreflexo == antirreflexoSwitch.isOn
            let fotossensivelFilter = b.len?.fotossensivel == fotossensivelSwitch.isOn
            let valueFilter = Double(b.total!) <= Double(valueSlider.value)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
                            
            let date = dateFormatter.string(from: self.datePicker.date)
                            
            let dateFilter = b.data == date
            
            return brandFilter && indiceFilter && antirreflexoFilter && fotossensivelFilter && valueFilter && dateFilter
            
        })
        
        return filterBudgtes
    }
    
    @IBAction func showFilteredBudgets(_ sender: UIButton) {
        Task { @MainActor in
            do {
                let allBudgetsWithLens = await getBudgets()
                
                let budgetsWithLens = await loadLensInBudgets(budgetsList: allBudgetsWithLens)
                
                let filtersBudgets = await filteringBudgets(budgetsList: budgetsWithLens)
                
                if filtersBudgets.isEmpty {
                    let alert = UIAlertController(title: "Nenhum orçamento encontrado!",
                                                  message: "Nenhum orçamento cadastrado com essas informações",
                                                  preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Fechar",
                                                  style: UIAlertAction.Style.cancel,
                                                  handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let mainVc = self.storyboard?.instantiateViewController(withIdentifier: "TableBudgets") as? BudgetsListViewController {
                        mainVc.filterBudgets = filtersBudgets
                        mainVc.budgets = filtersBudgets
                        mainVc.reloadTable = false
                        mainVc.navigationItem.setRightBarButtonItems(nil, animated: false)
                        self.navigationController?.pushViewController(mainVc, animated: true)
                    }
                }
                
            }
        }
    }
    
    @objc func cleanFilters() {
        brandMenu.setTitle("Todas", for: .normal)
        indiceMenu.setTitle("Todas", for: .normal)
    }
    
    @IBAction func changeMaxValue(_ sender: UISlider) {
        let step: Float = 100
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        maxValue.text = self.formatCurrentNumber(current: Double(valueSlider.value))
    }
}
