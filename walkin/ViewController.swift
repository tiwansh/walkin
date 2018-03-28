//
//  ViewController.swift
//  walkin
//
//  Created by fordlabs on 14/03/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var cdsid: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UITextField!
    var ref:DatabaseReference?
    
    @IBAction func saveBtn(_ sender: Any) {
        
        //guard let userKey = Auth.auth().currentUser?.uid else {return}
        
        if cdsid.text != "" && password.text != "" {
            Auth.auth().createUser(withEmail: cdsid.text!, password: password.text!) { (user, error) in
                if error == nil {
                    print ("yo")
                    self.addUser()
                    //self.ref?.child("users").child((user?.uid)!).setValue(self.cdsid.text!)
                    //self.ref?.child("names").child(userKey).setValue(self.name.text!)
                    //self.ref?.child("phone").child(userKey).setValue(self.phone.text!)
                }
                else{
                    print ("no")
                    print (error?.localizedDescription)
                }
            }
        }
        
    }
    
    func addUser(){
        ref = Database.database().reference().child("users")
        let key = Auth.auth().currentUser?.uid
        let user = ["id":key,
                    "cdsid":cdsid.text,
                    "name":name.text,
                    "phone":phone.text,
                    ]
        ref?.child(key!).setValue(user)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

