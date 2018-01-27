//
//  ViewController.swift
//  Pocket Money
//
//  Created by fanjianhua on 1/22/18.
//  Copyright © 2018 fanjianhua. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class ExpenseRecordController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let defaults = UserDefaults.standard
        
    var itemArray = [Item]()
    
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.object(forKey: "expense") != nil {
            expenseButton.title = "Expense: \(defaults.float(forKey: "expense"))"
        } else {
            expenseButton.title = "Expense: 0.0)"
        }
        tableView.separatorStyle = .none
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(.init(horizontal: 10, vertical: 5), for: UIBarMetrics.default)
        
        title = selectedCategory?.name
        
        
        guard let colorHex = selectedCategory?.color else {fatalError()}
            
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        updateNavBar(withHexCode: "28AAC0")
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    
    
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        
        let item = itemArray[indexPath.row]
        
        
        cell.titleLabel.text = item.title
        cell.priceLabel.text = item.price
        
//        cell.backgroundColor = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count))
//        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
//
////        cell.accessoryType = item.done ? .checkmark : .none
//
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        print(indexPath.row)
//
//
//
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//
//        self.saveItems()
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    //MARK: - Add New Items
    
    @IBOutlet weak var expenseButton: UIBarButtonItem!
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField1 = UITextField()
        var textField2 = UITextField()
        
        let alert = UIAlertController(title: "Add new Expense Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once the user clicks the button
            
            let newItem = Item(context: self.context)
            newItem.title = textField1.text!
            newItem.price = textField2.text!
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            var expense: Float = 0.0
            if self.defaults.object(forKey: "expense") != nil {
                expense = self.defaults.float(forKey: "expense")
            }
            let newexpense = expense + Float(newItem.price!)!
            self.defaults.set(newexpense, forKey: "expense")
            self.expenseButton.title = "Expense: \(newexpense)"
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "enter the name"
            textField1 = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "enter the price"
            textField2 = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Scan Button
    
    @IBAction func scan(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToScan", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // try
        if let destinationVC = segue.destination as? ScanTableViewController {
            destinationVC.selectedCategory = selectedCategory
        }
    }
    
    
    //MARK: - Model Manupulation Methods
    
    func saveItems() {
       
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
       
       
        self.tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
         self.tableView.reloadData()
        
    }
    
   
}

//MARK: - Search bar methods
extension ExpenseRecordController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}




