//
//  BudgetCell.swift
//  app_firebase
//
//  Created by Hermando Thiago Costa Fernandes on 20/12/22.
//

import UIKit

class BudgetCell: UITableViewCell {

    @IBOutlet weak var nameClientCell: UILabel!
    @IBOutlet weak var dateBudget: UILabel!
    @IBOutlet weak var phoneBudget: UILabel!
    @IBOutlet weak var emailBudget: UILabel!
    @IBOutlet weak var valueBudget: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
