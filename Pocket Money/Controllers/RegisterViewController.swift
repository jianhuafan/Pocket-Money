//
//  RegisterViewController.swift
//  Pocket Money
//
//  Created by fanjianhua on 1/24/18.
//  Copyright © 2018 fanjianhua. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    @IBAction func registerPressed(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil {
                print(error!)
            } else {
                print("registrastion sucessful!")
                
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
        destinationVC.selectedUser = user
    }
}
