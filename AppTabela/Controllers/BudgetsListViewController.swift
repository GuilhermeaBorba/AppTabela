//
//  BudgetsListViewController.swift
//  app_firebase
//
//  Created by user230281 on 11/25/22.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class BudgetsListViewController: UIViewController {
    
    @IBOutlet weak var tableBudget: UITableView!
    @IBOutlet weak var inputFilterBudget: UITextField!
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    var budgets: [Budget] = []
    var filterBudgets: [Budget] = []
    
    var reloadTable = true
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if reloadTable {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Filtros Avançados", style: .plain, target: self, action: #selector(toFilterBudgetsPage)),
                UIBarButtonItem(title: "Produtos", style: .plain, target: self, action: #selector(toProductsPage))
            ]
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Produtos", style: .plain, target: self, action: #selector(toProductsPage))]
        }
        
        tableBudget.delegate = self
        tableBudget.dataSource = self
        tableBudget.register(
            UINib(nibName: "BudgetCell", bundle: nil), forCellReuseIdentifier: "BudgetCell"
        )
        
        if filterBudgets.isEmpty {
            loadBudgets()
        }
        
    }
    
    @objc func toBack() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func toProductsPage() {
        guard let navigationController = navigationController else {
            return
        }
                
        if let mainViewController = navigationController.viewControllers.filter({ $0 is MainViewController }).first {
            navigationController.popToViewController(mainViewController, animated: true)
        }
    }
    
    @objc func toFilterBudgetsPage() {
        if let filterBudgets = self.storyboard?.instantiateViewController(withIdentifier: "FilterBudgets") as? AdvancedFilterBudgetsViewController {
            self.navigationController?.pushViewController(filterBudgets, animated: true)
        }
    }
    
    func loadBudgets(){
        db.collection("users/\(userID)/orcamentos")
            .addSnapshotListener { (querySnapshot, error) in
                
                self.budgets = []
                self.filterBudgets = []
                
                if let err = error {
                    print(err)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            let newBudget = Budget(
                                documentId: doc.documentID,
                                client: data["cliente"] as? String,
                                phone: data["telefone"] as? String,
                                email: data["email"] as? String,
                                frame: data["armacao"] as? String,
                                frameVale: data["valor_armacao"] as? Double,
                                discount: data["desconto"] as? Double,
                                total: data["total"] as? Double,
                                paymentForm: data["forma_pagamento"] as? String,
                                lensId: data["id_lente"] as! String,
                                data: data["data"] as? String
                            )
                            
                            self.budgets.append(newBudget)
                            self.filterBudgets.append(newBudget)
                            
                            DispatchQueue.main.async {
                                self.tableBudget.reloadData()
                            }
                            
                        }
                    }
                }
                
            }
    }
    
    @IBAction func filterBudgets(_ sender: UITextField) {
        if inputFilterBudget.text != "" {
            filterBudgets = budgets.filter{ $0.client!.lowercased().contains(inputFilterBudget.text!.lowercased()) }
            self.tableBudget.reloadData()
        } else if inputFilterBudget.text == "" {
            if reloadTable == false {
                filterBudgets = budgets
                self.tableBudget.reloadData()
            } else {
                loadBudgets()
            }
        }
    }
    
}

extension BudgetsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        let budgetCell = filterBudgets[indexPath.row]
        
        cell.nameClientCell.text = budgetCell.client!
        cell.dateBudget.text = budgetCell.data!
        cell.phoneBudget.text = budgetCell.phone!
        cell.emailBudget.text = budgetCell.email!
        cell.valueBudget.text = self.formatCurrentNumber(current: budgetCell.total!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterBudgets.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let budgetCell = filterBudgets[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "Excluir"){
            _, _, _ in
            self.filterBudgets.remove(at: indexPath.row)
            self.budgets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.db.collection("users/\(self.userID)/orcamentos").document(budgetCell.documentId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
        let edit = UIContextualAction(style: .normal, title: "Editar"){
            _, _, _ in
            
            let lensId = budgetCell.lensId
            
            self.db.collection("users/\(self.userID)/lentes").document(lensId).getDocument(source: .cache) {
                (document, error) in
                
                    if let doc = document {
                            let data = doc.data()
                            let product = Product(
                                documentId: doc.documentID,
                                descricao: data?["descricao"] as? String,
                                code: data?["code"] as? String,
                                nome: data?["nome"] as? String,
                                value:  data?["valor"] as? Double,
                                classificacao: data?["classificacao"] as? String,
                                marca: data?["marca"] as? String,
                                adicao_min: data!["adicao_min"] as? String,
                                adicao_max: data!["adicao_max"] as? String,
                                antirreflexo: data?["antirreflexo"] as! Bool,
                                fotossensivel: data?["fotossensivel"] as! Bool,
                                diametro: data?["diametro"] as? String,
                                esfera_min: data?["esfera_min"] as? String,
                                esfera_max: data?["esfera_max"] as? String,
                                cilindro: data?["cilindro"] as? String,
                                height: data?["altura"] as? String,
                                tipoLente: data?["tipo_lente"] as? String,
                                indice: data?["indice"] as? String,
                                photo: data?["photo"] as? String
                            )
                        
                        
                        if let editBudget = self.storyboard?.instantiateViewController(withIdentifier: "editBudget") as? EditBudgetViewController {
                            editBudget.budget = budgetCell
                            editBudget.product = product
                            editBudget.documentId = budgetCell.documentId
                            self.navigationController?.pushViewController(editBudget, animated: true)
                        }
                        
                    }
                
            }
            
            
        }
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return swipe
    }
}
