//
//  DialogPresenter.swift
//  AppTabela
//
//  Created by GaOptical Solutions on 26/07/23.
//

//import Foundation
//import UIKit
//import PopupDialog
//
//class DialogPresenter {
//    
//    static func presentDialog (target: UIViewController, title: String, message: String, animated: Bool) {
//        
//        // Create the dialog
//        
//        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
//            print("Clicado")
//        }
//        
//        //Create second button
//        let buttonTwo = DefaultButton(title: "OK"){
//            
//        }
//        
//        // Add buttons to Dialog
//        popup.addButtons([buttonTwo])
//   
//        // Present dialog
//        target.present(popup, animated: animated, completion: nil)
//    }
//    
//
//}
//
//extension UIViewController {
//    
//    func criarAlerta(titulo: String, mensagem: String){
//        
//        let alerta = PopupDialog(title: titulo, message: mensagem, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true)
//        
//        let acaoOK = DefaultButton(title: "OK"){
//            
//        }
//        
//        alerta.addButton(acaoOK)
//        
//        self.present(alerta, animated: true, completion: nil)
//    }
//    
//}
