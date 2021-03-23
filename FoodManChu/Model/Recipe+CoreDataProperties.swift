//
//  Recipe+CoreDataProperties.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/14/21.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var name: String?
    @NSManaged public var prepTime: Int64
    @NSManaged public var details: String?
    @NSManaged public var image: Image?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var category: Category?
    @NSManaged public var instructions: String?
    
    public var ingredientsArray: [Ingredients] {
        let set = ingredients as? Set<Ingredients> ?? []
        
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

}

// MARK: Generated accessors for ingredients
extension Recipe {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredients)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredients)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension Recipe : Identifiable {

}
