//
//  IngredientsLabel.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 3/13/21.
//

import UIKit

class IngredientsLabel: UILabel {
    override func awakeFromNib() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.systemGray.cgColor
    }
}
