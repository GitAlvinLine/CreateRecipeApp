//
//  Ingredients+CoreDataProperties.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/14/21.
//
//

import Foundation
import CoreData


extension Ingredients {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredients> {
        return NSFetchRequest<Ingredients>(entityName: "Ingredients")
    }

    @NSManaged public var name: String?
    @NSManaged public var recipe: Recipe?
    
    public var wrappedName: String {
        name ?? "Unknown Name"
    }

}

extension Ingredients : Identifiable {

}
