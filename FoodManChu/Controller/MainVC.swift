//
//  ViewController.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/11/21.
//
import CoreData
import UIKit

class MainVC: UIViewController {
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var controller: NSFetchedResultsController<Recipe>!
    var dietController: NSFetchedResultsController<Category>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        //generateDummyData()
        attemptFetch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.editRecipe {
            if let destination = segue.destination as? CustomizeRecipeVC {
                if let recipe = sender as? Recipe {
                    destination.recipeToEdit = recipe
                }
            }
        }
    }
}

// MARK: - UISearchBar
extension MainVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

// MARK: - IBActions
extension MainVC {
    @IBAction func addRecipeTapped(_ sender: UIButton){
        performSegue(withIdentifier: Constants.Segues.addRecipeIngredient, sender: self)
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        attemptFetch()
        tableView.reloadData()
    }
}

// MARK: - TableView Setup
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? RecipeCell else { return UITableViewCell() }
        
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objects = controller.fetchedObjects, objects.count > 0 {
            let recipe = objects[indexPath.row]
            performSegue(withIdentifier: Constants.Segues.editRecipe, sender: recipe)
        }
    }
    
    func configureCell(_ cell: RecipeCell, indexPath: IndexPath) {
        let recipe = controller.object(at: indexPath)
        cell.configureCell(recipe, indexPath)
    }
}

// MARK: - CoreData Setup
extension MainVC: NSFetchedResultsControllerDelegate {
    func generateDummyData() {
        let recipe1 = Recipe(context: Constants.context)
        recipe1.name = "Grilled Chicken with Rice"
        recipe1.prepTime = 20
        recipe1.details = "Cook grill chicken on pan for 10 mins on medium. Cook rice for 20 minutes."
        
        let recipe2 = Recipe(context: Constants.context)
        recipe2.name = "Fettucine Alfredo"
        recipe2.prepTime = 15
        recipe2.details = "Open your bag of fettucine alfredo and empty the bag in pan. Cook on medium for 15 minutes."
        
        let recipe3 = Recipe(context: Constants.context)
        recipe3.name = "Quesadilla"
        recipe3.prepTime = 6
        recipe3.details = "Get your flour tortilla and put cheese in the middle. Close tortilla and flip each side every 2 minutes"
        
        Constants.ad.saveContext()
    }
    
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let detailSort = NSSortDescriptor(key: "details", ascending: true)
        let timeSort = NSSortDescriptor(key: "prepTime", ascending: true)
        let category = NSSortDescriptor(keyPath: \Recipe.category?.name, ascending: true)
        
        let ingredients = \Recipe.ingredients // Recipe.ingredients is an NSSet
        
        fetchRequest.sortDescriptors = [nameSort,detailSort,timeSort,category]
        
        switch segmentController.selectedSegmentIndex {
        case 1:
            fetchRequest.sortDescriptors = [nameSort]
        case 2:
            fetchRequest.sortDescriptors = [detailSort]
        case 3:
            fetchRequest.sortDescriptors = [timeSort]
        case 4:
            fetchRequest.sortDescriptors = [category]
        default:
            break
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Constants.context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        do {
            try controller.performFetch()
        } catch let err {
            print(err)
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as? RecipeCell
                if cell == nil {
                    break
                } else {
                    configureCell(cell!, indexPath: indexPath)
                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        @unknown default:
            break
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
