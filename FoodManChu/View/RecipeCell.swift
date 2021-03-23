//
//  RecipeCell.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/14/21.
//

import UIKit

class RecipeCell: UITableViewCell {

    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // TODO: Configure your cell
    func configureCell(_ recipe: Recipe, _ indexPath: IndexPath){
        recipeNameLabel.text = recipe.name
        prepTimeLabel.text = "\(recipe.prepTime) minutes"
        detailsLabel.text = recipe.details
        instructionsLabel.text = recipe.instructions
        categoryLabel.text = recipe.category?.name
        
        // Convert NSSet from Data Model to String data type for Ingredients
        let set = recipe.ingredients as? Set<Ingredients>
        let array = set?.sorted(by: ({$0.name! < $1.name!}))
        var names = [String]()
        for ingredients in array! {
            names.append(ingredients.name!)
        }
        let stringNameRepresentation = names.joined(separator: ",")
        ingredientsLabel.text = stringNameRepresentation
    }

}
