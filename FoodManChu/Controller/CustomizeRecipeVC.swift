//
//  RecipeDetails.swift
//  FoodManChu
//
//  Created by Alvin Escobar on 2/13/21.
//
import CoreData
import UIKit

class CustomizeRecipeVC: UIViewController {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var instructionsTextField: UITextField!
    @IBOutlet weak var addIngredientTextField: UITextField!
    @IBOutlet weak var dietCategoryTextField: UITextField!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    var dietCategoryPickerView = UIPickerView()
    var ingredientPickerView = UIPickerView()
    
    var dietCategories: [Category] = []
    var ingredientsToChoose: [Ingredients] = []
    var ingredientsSelected: [Ingredients] = []
    var recipeToEdit: Recipe?
    
    var controller: NSFetchedResultsController<Ingredients>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dietCategoryPickerView.delegate = self
        dietCategoryPickerView.dataSource = self
        
        ingredientPickerView.delegate = self
        ingredientPickerView.dataSource = self
        
        setupToolBar()
        setupInputViews()
        
        //generateDietCategories()
        //generateDummyIngredients()
        
        if recipeToEdit != nil {
            loadExistingRecipe()
        }
    }
    
    // MARK: - Load Existing Recipe
    func loadExistingRecipe() {
        if let recipe = recipeToEdit {
            titleTextField.text = recipe.name
            minuteTextField.text = "\(recipe.prepTime)"
            descriptionTextField.text = recipe.details
            instructionsTextField.text = recipe.instructions
            thumbImageView.image = recipe.image?.image as? UIImage
            
            // TODO: Load existing recipe ingredients
            let set = recipe.ingredients as? Set<Ingredients>
            let array = set?.sorted(by: ({$0.name! < $1.name!}))
            var names = [String]()
            for elements in array! {
                names.append(elements.name!)
            }
            let stringNameRepresentation = names.joined(separator: ",")
            ingredientsLabel.text = stringNameRepresentation
            
            // TODO: Load exisiting recipe category UIPickerView
            if let category = recipe.category {
                var index = 0
                repeat {
                    let diet = dietCategories[index]
                    if diet.name == category.name {
                        dietCategoryPickerView.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    index += 1
                } while (index < dietCategories.count)
            }
        }
    }
    
    // MARK: - Setup TextField InputViews as PickerView
    func setupInputViews() {
        getDietCategories()
        getIngredients()
        
        addIngredientTextField.inputView = ingredientPickerView
        dietCategoryTextField.inputView = dietCategoryPickerView
        
        ingredientPickerView.tag = 1
        dietCategoryPickerView.tag = 2
    }
    
    // MARK: - Setup Tool Bar / Done button on Keyboard
    func setupToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        // have the done button on the right side of tool bar
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolBar.items = [flexSpace,doneButton]
        toolBar.sizeToFit()
        
        titleTextField.inputAccessoryView = toolBar
        minuteTextField.inputAccessoryView = toolBar
        descriptionTextField.inputAccessoryView = toolBar
        instructionsTextField.inputAccessoryView = toolBar
        addIngredientTextField.inputAccessoryView = toolBar
        dietCategoryTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
}

// MARK: - IBActions
extension CustomizeRecipeVC {
    @IBAction func saveTapped(_ sender: UIButton){
        var recipe: Recipe!
        
        if recipeToEdit != nil {
            recipe = recipeToEdit
            let set = recipeToEdit?.ingredients as? Set<Ingredients>
            var array = set?.sorted(by: ({$0.name! < $1.name!}))
            array?.append(contentsOf: ingredientsSelected)
            recipe.ingredients = NSSet(array: array!)
            recipe.category = dietCategories[dietCategoryPickerView.selectedRow(inComponent: 0)]
            Constants.ad.saveContext()
            navigationController?.popViewController(animated: true)
        } else {
            guard let name = titleTextField.text, !name.isEmpty,
                  let minutes = minuteTextField.text, !minutes.isEmpty,
                  let details = descriptionTextField.text, !details.isEmpty,
                  let instructions = instructionsTextField.text, !instructions.isEmpty,
                  let ingredients = ingredientsLabel.text, !ingredients.isEmpty
            else {
                let alert = UIAlertController(title: "You need to select every option to save recipe.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
        
            recipe = Recipe(context: Constants.context)
            recipe.name = name
            recipe.prepTime = Int64(minutes)!
            recipe.details = details
            recipe.instructions = instructions
            recipe.category = dietCategories[dietCategoryPickerView.selectedRow(inComponent: 0)]
            
            
            // convert array to NSSet
            recipe.ingredients = NSSet(array: ingredientsSelected)
            
            
            Constants.ad.saveContext()
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func deleteTapped(_ sender: UIButton){
        if recipeToEdit != nil {
            Constants.context.delete(recipeToEdit!)
            Constants.ad.saveContext()
            navigationController?.popViewController(animated: true)
        } else {
            titleTextField.text = ""
            minuteTextField.text = ""
            descriptionTextField.text = ""
            instructionsTextField.text = ""
            ingredientsLabel.text = ""
            addIngredientTextField.text = ""
            dietCategoryPickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    @IBAction func cloneRecipeTapped(_ sender: UIButton){
        var recipe: Recipe!
        if recipeToEdit == nil {
            let alert = UIAlertController(title: "You can't clone something that has not been created yet.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            recipe = Recipe(context: Constants.context)
            guard let name = titleTextField.text, !name.isEmpty,
                  let minutes = minuteTextField.text, !minutes.isEmpty,
                  let details = descriptionTextField.text, !details.isEmpty,
                  let instructions = instructionsTextField.text, !instructions.isEmpty
            else {
                return
            }
            
            recipe.name = name
            recipe.prepTime = Int64(minutes)!
            recipe.details = details
            recipe.instructions = instructions
            recipe.ingredients =  recipeToEdit?.ingredients
            recipe.category = dietCategories[dietCategoryPickerView.selectedRow(inComponent: 0)]
            Constants.ad.saveContext()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addImageTapped(_ sender: UIButton){
        
    }
    
    @IBAction func addIngredientTapped(_ sender: UIButton) {
        //var ingredient: Ingredients!
        
        guard let text = addIngredientTextField.text, !text.isEmpty
        else {
            let alert = UIAlertController(title: "You need to enter an ingredient.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
//        ingredient = Ingredients(context: Constants.context)
//        ingredient.name = text
        ingredientsSelected.append(ingredientsToChoose[ingredientPickerView.selectedRow(inComponent: 0)])
        addIngredientTextField.text = ""
        
        if ingredientsLabel.text == "" {
            ingredientsLabel.text = text
        } else {
            ingredientsLabel.text! += ", \(text)"
        }
        
    }
}


// MARK: - UIPickerView Setup
extension CustomizeRecipeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return ingredientsToChoose.count
        case 2:
            return dietCategories.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch pickerView.tag {
        case 1:
            return ingredientsToChoose[row].name
        case 2:
            return dietCategories[row].name
        default:
            return "Data Not Found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            addIngredientTextField.text = ingredientsToChoose[row].name
        case 2:
            dietCategoryTextField.text = dietCategories[row].name
        default:
            return
        }
    }
}

// MARK: - UIPickerView Recipe Categories Generated
extension CustomizeRecipeVC{
    func generateDietCategories() {
        let meat = Category(context: Constants.context)
        meat.name = "Meat"
        
        let vegetarian = Category(context: Constants.context)
        vegetarian.name = "Vegetarian"
        
        let vegan = Category(context: Constants.context)
        vegan.name = "Vegan"
        
        let paleo = Category(context: Constants.context)
        paleo.name = "Paleo"
        
        let keto = Category(context: Constants.context)
        keto.name = "Keto"
        
        Constants.ad.saveContext()
    }
    
    
    func getDietCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [nameSort]
        
        do {
            self.dietCategories = try Constants.context.fetch(fetchRequest)
            print(dietCategories.count)
            self.dietCategoryPickerView.reloadAllComponents()
        } catch let err {
            print(err)
        }
    }
}

// MARK: - UIPickerView Ingredients Generated
extension CustomizeRecipeVC {
    func getIngredients() {
        let fetchRequest: NSFetchRequest<Ingredients> = Ingredients.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)

        fetchRequest.sortDescriptors = [nameSort]
        
        do {
            self.ingredientsToChoose = try Constants.context.fetch(fetchRequest)
            print(ingredientsToChoose.count)
            
            self.ingredientPickerView.reloadAllComponents()
        } catch let err {
            print(err)
        }
        
    }
    
    func generateDummyIngredients() {
        let salt = Ingredients(context: Constants.context)
        salt.name = "Salt"
        
        let pepper = Ingredients(context: Constants.context)
        pepper.name = "Pepper"
        
        let oliveOil = Ingredients(context: Constants.context)
        oliveOil.name = "Olive Oil"
        
        let vegetableOil = Ingredients(context: Constants.context)
        vegetableOil.name = "Vegetable Oil"
        
        let flour = Ingredients(context: Constants.context)
        flour.name = "Flour"
        
        let sugar = Ingredients(context: Constants.context)
        sugar.name = "Sugar"
        
        let tuna = Ingredients(context: Constants.context)
        tuna.name = "Tuna"
        
        let chicken = Ingredients(context: Constants.context)
        chicken.name = "Chicken"
        
        let beans = Ingredients(context: Constants.context)
        beans.name = "Beans"
        
        let rice = Ingredients(context: Constants.context)
        rice.name = "Rice"
        
        let broccoli = Ingredients(context: Constants.context)
        broccoli.name = "Broccoli"
        
        let spinach = Ingredients(context: Constants.context)
        spinach.name = "Spinach"
        
        let pasta = Ingredients(context: Constants.context)
        pasta.name = "Pasta"
        
        let onions = Ingredients(context: Constants.context)
        onions.name = "Onions"
        
        let potatoes = Ingredients(context: Constants.context)
        potatoes.name = "Potatoes"
        
        let garlic = Ingredients(context: Constants.context)
        garlic.name = "Garlic"
        
        let egg = Ingredients(context: Constants.context)
        egg.name = "Egg"
        
        let milk = Ingredients(context: Constants.context)
        milk.name = "Milk"
        
        let butter = Ingredients(context: Constants.context)
        butter.name = "Butter"
        
        let ketchup = Ingredients(context: Constants.context)
        ketchup.name = "Ketchup"
        
        let cheese = Ingredients(context: Constants.context)
        cheese.name = "Cheese"
        
        Constants.ad.saveContext()
    }
}



