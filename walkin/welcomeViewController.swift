//
//  welcomeViewController.swift
//  walkin
//
//  Created by fordlabs on 15/03/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Firebase

class welcomeViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        display.text = "Login succesful !"
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
