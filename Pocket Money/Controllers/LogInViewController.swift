//
//  LogInViewController.swift
//  Pocket Money
//
//  Created by fanjianhua on 1/24/18.
//  Copyright © 2018 fanjianhua. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    

    @IBAction func logInPressed(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil {
                print(error!)
            } else {
                print("Log in successful!")
                
                self.performSegue(withIdentifier: "goToCategory", sender: self)
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // try
        let destinationVC = segue.destination as! CategoryViewController
        let user = User(context: self.context)
        let userID = Auth.auth().currentUser!.uid
        user.userUID = userID
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
//        let entity = NSEntityDescription.entity(forEntityName: "User", in: self.context)
//        let newUser = NSManagedObject(entity: entity!, insertInto: self.context)
//        newUser.setValue(userID, forKey: "userUID")
          destinationVC.selectedUser = user
    }
    
}
