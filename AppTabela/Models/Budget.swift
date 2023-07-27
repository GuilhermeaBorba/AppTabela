//
//  Budget.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 20/12/22.
//

import Foundation

struct Budget {
    let documentId: String
    let client: String?
    let phone: String?
    let email: String?
    let frame: String?
    let frameVale: Double?
    let discount: Double?
    let total: Double?
    let paymentForm: String?
    let lensId: String
    let data: String?
    var len: Product?
    
    mutating func defineLen(product: Product) async {
        self.len = product
    }
    
}
