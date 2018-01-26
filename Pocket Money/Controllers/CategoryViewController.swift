//
//  CategoryViewController.swift
//  Pocket Money
//
//  Created by fanjianhua on 1/23/18.
//  Copyright © 2018 fanjianhua. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import Firebase


class CategoryViewController: SwipeTableViewController {
    
    var categoryArray = [Category]()
    
    var selectedUser : User? {
        didSet{
            loadCategories()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        loadCategories()
        
        tableView.separatorStyle = .none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
  

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        guard let categoryColor = UIColor(hexString: category.color!) else {fatalError()}
        
        cell.backgroundColor = categoryColor
        
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        
        return cell
        
    }
    
     //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // try
        let destinationVC = segue.destination as! ExpenseRecordController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            //What will happen once the user clicks the button
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            newCategory.parentUser = self.selectedUser
            self.categoryArray.append(newCategory)
            self.saveCategories()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Creat new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
   
    
    
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        let userPredicate = NSPredicate(format: "parentUser.userUID MATCHES %@", selectedUser!.userUID!)
        request.predicate = userPredicate
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        self.context.delete(self.categoryArray[indexPath.row])
        self.categoryArray.remove(at: indexPath.row)
        
    }
    
    
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("error, there was a problem signing out.")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil else {
            print("No view controllers to pop off")
            return
        }
    }
    
}




