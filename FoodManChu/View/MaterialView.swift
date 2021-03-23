//
//  MaterialView.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/14/21.
//

import Foundation
import UIKit


extension UIView {
    @IBInspectable var materialDesign: Bool {
        get {
            return Constants.materialKey
        }
        
        set {
            Constants.materialKey = newValue
            
            if Constants.materialKey == true {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 3.0
                self.layer.shadowOpacity = 0.8
                self.layer.shadowRadius = 3.0
                self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                self.layer.shadowColor = #colorLiteral(red: 0.6156862745, green: 0.6156862745, blue: 0.6156862745, alpha: 1)
            } else {
                self.layer.cornerRadius = 0
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 0
                self.layer.shadowColor = nil
            }
        }
        
    }
}
