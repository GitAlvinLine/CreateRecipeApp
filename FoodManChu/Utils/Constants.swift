//
//  Constants.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/13/21.
//

import Foundation
import UIKit

enum Constants {
    static var materialKey: Bool = false
    static let ad = UIApplication.shared.delegate as! AppDelegate
    static let context = ad.persistentContainer.viewContext
    static let cellReuseId = "RecipeCell"
    static let ingredientCellReuseId = "ingredientCell"
    
    enum Segues {
        static let addRecipeIngredient = "addRecipe"
        static let editRecipe = "editRecipe"
        static let detailRecipe = "DetailRecipe"
    }
}
