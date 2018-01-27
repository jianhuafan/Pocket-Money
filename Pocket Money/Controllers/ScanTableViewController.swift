//
//  ScanTableViewController.swift
//  Pocket Money
//
//  Created by fanjianhua on 1/25/18.
//  Copyright © 2018 fanjianhua. All rights reserved.
//

import UIKit
import TesseractOCR
import CoreData

class ScanTableViewController: UITableViewController {
    
    var selectedCategory : Category?
    
    //temp array
    var items: [PriceItem] = []
    
    
    //CoreData
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedCategory != nil {
            self.popUp()
        }
    }
    
    
    @IBAction func Scan(_ sender: UIButton) {
        self.imageRecognition(image: imagePicked.image!)
         self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }

    
      //recognize photos with tesseract
    private func imageRecognition(image: UIImage) {
        
        // Initiate Tessearct
        if let tesseract = G8Tesseract(language: "eng") {
            
            tesseract.pageSegmentationMode = .auto
            tesseract.maximumRecognitionTime = 60.0
            
            tesseract.image = imagePicked.image
            
            tesseract.recognize()
            self.processText(recognizedText: tesseract.recognizedText)
        }
    }
    

    private func processText(recognizedText: String) {
        
        var allLines: [String] = []
        var text:String! = recognizedText
        var range:Range<String.Index>?
        range = text.range(of: "\n")
        
        while range != nil {
            
            // Get index from beginning of text to \n
            let index = text.startIndex ..< (range?.lowerBound)!
            
            // Create the line of string with index
            let line = text[index]
            
            // Append the line
            allLines.append(String(line))
            
            // Get index for after the the \n to the end
            let index2 = text.index(after: (range?.lowerBound)!) ..< text.endIndex
            
            // Update the text with the index
            text = String(text[index2])
            
            // Attempts to find \n
            range = text.range(of: "\n")
        }
        
        // Remove all whitespace form allLines array
        allLines = allLines.filter{ !$0.trimmingCharacters(in: .whitespaces).isEmpty}
        
        for line in allLines {
            print(line)
            let item = PriceItem(name: line, price: 0)
            items.append(item)
        
            let newItem = Item(context: self.context)
            newItem.title = line
            newItem.price = "0.0"
            newItem.parentCategory = selectedCategory
            self.itemArray.append(newItem)
        }
       self.saveItems()
    }


    @IBAction func done(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // try
        if let destinationVC = segue.destination as? ExpenseRecordController {
            destinationVC.selectedCategory = selectedCategory
        }
    }
    
    
    
}

//MARK: - Scan Methods

extension ScanTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicked.image = image
        dismiss(animated:true, completion: nil)
    }
    
    func popUp() {
        let alert = UIAlertController(title: "Please select your way of choosing receipts", message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "use camera", style: .default) { (action) in
            //What will happen once the user clicks the button
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let action2 = UIAlertAction(title: "select photos from library", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }
        alert.addAction(action1)
        alert.addAction(action2)
        
        
        present(alert, animated: true)
    }
}

//MARK: - Diplay all the items

extension ScanTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 0.15)
        return cell
    }
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    


}


