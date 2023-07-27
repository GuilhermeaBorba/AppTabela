//
//  PolarizadaVC.swift
//  AppTabela
//
//  Created by GaOptical Solutions on 26/07/23.
//

import UIKit
import PopupDialog

class PolarizadaVC: UIViewController {
    
    @IBOutlet weak var fundoPolar: UIImageView!
    
    var controle = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPolar(_ sender: UIButtonX) {
        
        self.controle = sender.tag
        
        switch sender.tag {
        case 1:
            UIView.transition(with: self.fundoPolar,
                              duration:0.3,
                              options: .transitionCrossDissolve,
                              animations: { self.fundoPolar.image = UIImage(named: "sem_polarizada") },
                              completion: nil)
        case 2:
            UIView.transition(with: self.fundoPolar,
                              duration:0.3,
                              options: .transitionCrossDissolve,
                              animations: { self.fundoPolar.image = UIImage(named: "polarizada") },
                              completion: nil)
        default:
            break
        }
    }
    
    
//    @IBAction func btnInfo(_ sender: UIButtonX) {
//        
//        self.criarAlerta(titulo: "Lentes Polarizadas", mensagem: "Ideais para motoristas, pescadores!")
//    }
    

}
