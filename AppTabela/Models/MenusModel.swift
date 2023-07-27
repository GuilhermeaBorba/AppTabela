//
//  MenusModel.swift
//  app_firebase
//
//  Created by user230281 on 12/5/22.
//

import Foundation
import UIKit

class Menus {
    public func generateAdition() -> [String] {
        var initialNumber = 0.25
            
        var aditions: [String] = [String(format: "%.2f", initialNumber)]
        
        while initialNumber < 4.00 {
            initialNumber = initialNumber + 0.25
            
            if initialNumber > 0 {
                let positiveAdition = String(format: "%.2f", initialNumber)
                aditions.append(positiveAdition)
            } else {
                aditions.append(String(format: "%.2f", initialNumber))
            }
            
        }
        
        return aditions
    }
    
    public func generateValuesDegree() -> [String] {
        var initialValue = -30.00
        
        var degrees: [String] = [String(format: "%.2f", initialValue)]
        
        while initialValue < 30.00 {
            initialValue = initialValue + 0.25
            
            if initialValue > 0 {
                let positiveDegree = String(format: "+%.2f", initialValue)
                degrees.append(positiveDegree)
            } else {
                degrees.append(String(format: "%.2f", initialValue))
            }
        }
        
        return degrees
    }
    
    public func MenuTypeLens(sender: UIButton) -> UIMenu {
        let all = UIAction(title: "Todas"){
            _ in
            sender.setTitle("Todas", for: .normal)
        }
        
        let visaoSimples = UIAction(title: "Visão simples"){
            _ in
            sender.setTitle("Visão simples", for: .normal)
        }
        
        let bifocal = UIAction(title: "Bifocal"){
            _ in
            sender.setTitle("Bifocal", for: .normal)
        }
        
        let progressivo = UIAction(title: "Progressivo"){
            _ in
            sender.setTitle("Progressivo", for: .normal)
        }
        
        let lentePronta = UIAction(title: "Lente pronta"){
            _ in
            sender.setTitle("Lente pronta", for: .normal)
        }
        
        let menu = UIMenu(
                    title: "Tipos de lentes",
                    children: [
                        all,
                        visaoSimples, bifocal,
                        progressivo, lentePronta
                    ])
        return menu
    }
    
    public func MenuIndices(sender: UIButton) -> UIMenu {
        let all = UIAction(title: "Todas"){
            _ in
            sender.setTitle("Todas", for: .normal)
        }
        
        let value1 = UIAction(title: "1.49"){
            _ in
            sender.setTitle("1.49", for: .normal)
        }
        
        let value2 = UIAction(title: "1.56"){
            _ in
            sender.setTitle("1.56", for: .normal)
        }
        
        let value3 = UIAction(title: "1.59"){
            _ in
            sender.setTitle("1.59", for: .normal)
        }
        
        let value4 = UIAction(title: "1.60"){
            _ in
            sender.setTitle("1.60", for: .normal)
        }
        
        let value5 = UIAction(title: "1.67"){
            _ in
            sender.setTitle("1.67", for: .normal)
        }
        
        let value6 = UIAction(title: "1.70"){
            _ in
            sender.setTitle("1.70", for: .normal)
        }
        
        let value7 = UIAction(title: "1.74"){
            _ in
            sender.setTitle("1.74", for: .normal)
        }
        
        let value8 = UIAction(title: "1.80"){
            _ in
            sender.setTitle("1.80", for: .normal)
        }
        
        let value9 = UIAction(title: "1.90"){
            _ in
            sender.setTitle("1.90", for: .normal)
        }
        
        let menu = UIMenu(
            title: "Indices",
            children: [
                all, value1, value2, value3,
                value4, value5, value6,
                value7, value8, value9
            ]
        )
        
        return menu
    }
    
    public func MenuClassifications(sender: UIButton) -> UIMenu {
        let all = UIAction(title: "Todas"){
            _ in
            sender.setTitle("Todas", for: .normal)
        }
        
        let one = UIAction(title: "1"){
            _ in
            sender.setTitle("1", for: .normal)
        }
        
        let two = UIAction(title: "2"){
            _ in
            sender.setTitle("2", for: .normal)
        }
        
        let three = UIAction(title: "3"){
            _ in
            sender.setTitle("3", for: .normal)
        }
        
        let four = UIAction(title: "4"){
            _ in
            sender.setTitle("4", for: .normal)
        }
        
        let five = UIAction(title: "5"){
            _ in
            sender.setTitle("5", for: .normal)
        }
        
        let menu = UIMenu(
                    title: "Tipos de lentes",
                    children: [all, one, two, three, four, five]
                    )
        
        return menu
    }
    
    public func MenuPaymentMehod(sender: UIButton) -> UIMenu {
        let vista = UIAction(title: "À vista"){
            _ in
            sender.setTitle("À vista", for: .normal)
        }
        
        let cartao = UIAction(title: "Cartão de crédito"){
            _ in
            sender.setTitle("Cartão de crédito", for: .normal)
        }
        
        let menu = UIMenu(
            title: "Métodos de pagamento",
            children: [vista, cartao]
        )
        
        return menu
    }
    
}
