//
//  ViewController.swift
//  AppTabela
//
//  Created by GaOptical Solutions on 26/07/23.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    var controleMenu = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btnsMenu(_ sender: UIButton) {
        
        
        controleMenu = sender.tag
        
        switch controleMenu {
        case 1:
            self.performSegue(withIdentifier: "segueProgressivo", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "segueVs", sender: nil)
        case 3:
            self.performSegue(withIdentifier: "segueOcupacional", sender: nil)
        case 4:
            self.performSegue(withIdentifier: "segueTratamento", sender: nil)
        case 5:
            self.performSegue(withIdentifier: "segueTransitions", sender: nil)
        case 6:
            self.performSegue(withIdentifier: "segueEspessura", sender: nil)
        case 7:
            self.performSegue(withIdentifier: "seguePolarizada", sender: nil)
        case 8:
            self.performSegue(withIdentifier: "segueTabela", sender: nil)
  
        default:
            break
        }
        
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main2", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
    }
    

}


