//
//  ViewController.swift
//  app_firebase
//
//  Created by user230281 on 11/24/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableViewProducts: UITableView!
    @IBOutlet weak var searctTextField: UITextField!
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    var products: [Product] = []
    var filterProducts: [Product] = []
    var images: [UIImage] = []
    
    var loading: UIAlertController?
    var count = 1
    
    var reloadTable: Bool = true
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewProducts.delegate = self
        tableViewProducts.dataSource = self
        tableViewProducts.register(
            UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if filterProducts.isEmpty {
            //loading = self.loader(message: "Carregando tabela")
            loadProducts()
        }
        
        if reloadTable {
            loadProducts()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func loadProducts(){
        let docRef = db.collection("users/\(userID)/lentes")
        
        docRef.addSnapshotListener { (querySnapshot, error) in
            
            self.products = []
            self.filterProducts = []
            
            if let err = error {
                print(err)
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let newProduct = Product(
                            documentId: doc.documentID,
                            descricao: data["descricao"] as? String,
                            code: data["code"] as? String,
                            nome: data["nome"] as? String,
                            value:  data["valor"] as? Double,
                            classificacao: data["classificacao"] as? String,
                            marca: data["marca"] as? String,
                            adicao_min: data["adicao_min"] as? String,
                            adicao_max: data["adicao_max"] as? String,
                            antirreflexo: data["antirreflexo"] as? Bool,
                            fotossensivel: data["fotossensivel"] as? Bool,
                            diametro: data["diametro"] as? String,
                            esfera_min: data["esfera_min"] as? String,
                            esfera_max: data["esfera_max"] as? String,
                            cilindro: data["cilindro"] as? String,
                            height: data["altura"] as? String,
                            tipoLente: data["tipo_lente"] as? String,
                            indice: data["indice"] as? String,
                            photo: data["photo"] as? String
                        )
                        
                        self.products.append(newProduct)
                        self.filterProducts.append(newProduct)
                        
                        DispatchQueue.main.async {
                            self.tableViewProducts.reloadData()
                            
                            if self.loading != nil {
                                self.stopLoader(loader: self.loading!)
                            }

                        }
                        
                    }
                }
                
            }
        }
    }
    
    @IBAction func searchData(_ sender: UITextField) {
        if let searchText = searctTextField.text, !searchText.isEmpty {
            let words = searchText.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
            
               filterProducts = products.filter { product in
                   guard let nome = product.nome?.lowercased() else {
                       return false
                   }
                   return words.allSatisfy { nome.contains($0) }
               }
            self.tableViewProducts.reloadData()
           } else {
               if reloadTable == false {
                   filterProducts = products
                   self.tableViewProducts.reloadData()
               } else {
                   loadProducts()
               }
           }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterProducts.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let productCell = filterProducts[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "Excluir") {
            _, _, _ in
            
            let alert = UIAlertController(title: "Cuidado!", message: "Ao excluir esse produto, você estará excluindo todos os orçamentos ligados a ele", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Excluir", style: UIAlertAction.Style.default, handler: {
                _ in
                self.filterProducts.remove(at: indexPath.row)
                self.products.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.db.collection("users/\(self.userID)/lentes").document(productCell.documentId).delete()
                self.db.collection("users/\(self.userID)/orcamentos")
                    .whereField("id_lente", isEqualTo: productCell.documentId)
                    .getDocuments(){ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                self.db.collection("orcamentos").document(document.documentID).delete()
                            }
                        }
                    }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Editar"){
            _, _, _ in
            if let editVc = self.storyboard?.instantiateViewController(withIdentifier: "Edit") as? EditProductViewController {
                editVc.documentId = productCell.documentId
                editVc.product = productCell
                
                self.navigationController?.pushViewController(editVc, animated: true)
            }
        }
        
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return swipe
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ProductCell
        
        let productCell = filterProducts[indexPath.row]

        cell.documentId = productCell.documentId
        
        cell.nameProduct.text = productCell.nome
        cell.codeProduct.text = "COD: \(productCell.code!)"
        cell.valueProduct.text = self.formatCurrentNumber(current: productCell.value!)
        cell.classificationProduct.text = productCell.classificacao
        cell.brandProduct.text = productCell.marca
        cell.typeProduct.text = productCell.tipoLente
        cell.aditionProduct.text = "\(productCell.adicao_min!) a \(productCell.adicao_max!)"
        cell.fotossensivelProduct.text = productCell.fotossensivel ? "SIM" : "NAO"
        cell.antirreflexoPoduct.text = productCell.antirreflexo ? "SIM" : "NAO"
        cell.esfProduct.text = "\(productCell.esfera_min!) a \(productCell.esfera_max!)"
        cell.indiceProduct.text = productCell.indice
        cell.heightProduct.text = productCell.height
        cell.diameterProduct.text = productCell.diametro
        cell.cilProduct.text = productCell.cilindro
        
        if let url = URL(string: productCell.photo!), url.absoluteString == productCell.photo {
               cell.productImage.loadImage(fromURL: url, placeHolderImage: "photo")
           } else {
               cell.productImage.image = UIImage(named: "photo")
           }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let product = filterProducts[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: indexPath.row as NSCopying, previewProvider: nil) { _ -> UIMenu? in
            let createBudget = UIAction(title: "Criar orçamento") { _ in
                if let createBudgetVC = self.storyboard?.instantiateViewController(withIdentifier: "createBudget") as? BudgetsViewController {
                    createBudgetVC.product = product
                    self.navigationController?.pushViewController(createBudgetVC, animated: true)
                }
            }
            
            let compareBudget = UIAction(title: "Comparar") {
                _ in
                
                self.db.collection("users/\(self.userID)/lentes")
                    .whereField("classificacao", isEqualTo: product.classificacao!)
                    .limit(to: 3)
                    .getDocuments {
                        (querySnaphot, error) in
                    
                        var compareProducts: [Product] = []
                        
                        if let err = error {
                            print(err)
                        } else {
                            if let snapshotDocuments = querySnaphot?.documents {
                                for doc in snapshotDocuments {
                                    let data = doc.data()
                                    let newProduct = Product(
                                        documentId: doc.documentID,
                                        descricao: data["descricao"] as? String,
                                        code: data["code"] as? String,
                                        nome: data["nome"] as? String,
                                        value:  data["valor"] as? Double,
                                        classificacao: data["classificacao"] as? String,
                                        marca: data["marca"] as? String,
                                        adicao_min: data["adicao_min"] as? String,
                                        adicao_max: data["adicao_max"] as? String,
                                        antirreflexo: data["antirreflexo"] as! Bool,
                                        fotossensivel: data["fotossensivel"] as! Bool,
                                        diametro: data["diametro"] as? String,
                                        esfera_min: data["esfera_min"] as? String,
                                        esfera_max: data["esfera_max"] as? String,
                                        cilindro: data["cilindro"] as? String,
                                        height: data["altura"] as? String,
                                        tipoLente: data["tipo_lente"] as? String,
                                        indice: data["indice"] as? String,
                                        photo: data["photo"] as? String
                                    )
                                    
                                    compareProducts.append(newProduct)
                                    
                                }
                                
                                if compareProducts.count < 3 {
                                    let alert = UIAlertController(title: "Sem produtos suficientes para comparação!",
                                                                  message: "Deve ter pelo menos 3 produtos com a mesma classificação",
                                                                  preferredStyle: UIAlertController.Style.alert)
                                    
                                    alert.addAction(UIAlertAction(title: "Fechar",
                                                                  style: UIAlertAction.Style.destructive,
                                                                  handler: nil))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                } else if compareProducts.count == 3 {
                                    if let compareVc = self.storyboard?.instantiateViewController(withIdentifier: "compare") as? CompareViewController {
                                        compareVc.products = compareProducts
                                        compareVc.modalPresentationStyle = .fullScreen
                                        self.navigationController?.pushViewController(compareVc, animated: true)
                                    }
                                }
                                
                            }
                        }
                        
                    }
            }
            
            let menu = UIMenu(children: [createBudget, compareBudget])
            
            return menu
        }
    }
    
}
