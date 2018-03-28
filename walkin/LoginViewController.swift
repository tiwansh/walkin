//
//  LoginViewController.swift
//  walkin
//
//  Created by fordlabs on 14/03/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var labelTop: UILabel!
    @IBOutlet weak var cdsid: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginBtn(_ sender: Any) {
        Auth.auth().signIn(withEmail: cdsid.text!, password: password.text!) { (user, error) in
            if let error = error {
                print (error.localizedDescription)
                self.errorLabel.text = "Wrong credentials!"
                self.errorLabel.isHidden = false
            }
            else if let user = Auth.auth().currentUser{
                //let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("VerifyUserVC") as! VerifyUserVC
                //self.presentViewController(nextViewController, animated: true, completion: nil)
              
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "SweetHomeViewController") as! SweetHomeViewController
                self.present(nextViewController, animated: true, completion: nil)            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print ("user logged in")
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "SweetHomeViewController") as! SweetHomeViewController
                self.present(nextViewController, animated: true, completion: nil)
            }
            else{
                //Do nothing
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
