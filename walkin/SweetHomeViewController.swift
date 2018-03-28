//
//  welcome1ViewController.swift
//  walkin
//
//  Created by fordlabs on 15/03/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import CoreLocation

class SweetHomeViewController: UIViewController {
    
    let kUUIDKey = "monitor-proximityUUID"
    let kMajorIdKey = "monitor-transmit-majorId"
    let kMinorIdKey = "monitor-transmit-minorId"
    let uuidDefault = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
    @IBOutlet weak var regionIdLabel: UILabel!
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var minorTextField: UITextField!
    
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var monitorButton: UIButton!
    
    @IBOutlet weak var display: UILabel!
    var ref: DatabaseReference!
    
    var isMonitoring: Bool = false
    let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIInputViewController.dismissKeyboard))
    var regionMonitor: RegionMonitor!
    let distanceFormatter = LengthFormatter()
    var major = 123
    var minor = 123
    var uuid = NSUUID(uuidString: "b9407f30-f5f8-466e-aff9-25556b57fe6d")
    var identifier = "my.beacon"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uuidTextField.delegate = self
        majorTextField.delegate = self
        minorTextField.delegate = self
        regionMonitor = RegionMonitor(delegate: self)
        initFromDefaultValues()
        displayName()
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
    }
    
    func getLocation() -> CLLocation {
        let location = regionMonitor.locationManager.location!
        return location
    }
    
    private func initFromDefaultValues() {
        let defaults = UserDefaults.standard
        if let uuid = defaults.string(forKey: kUUIDKey) {
            uuidTextField.text = uuid
        }
        if let major = defaults.string(forKey: kMajorIdKey) {
            majorTextField.text = major
        }
        if let minor = defaults.string(forKey: kMinorIdKey) {
            minorTextField.text = minor
        }
    }

    func dismissKeyboard() {
        uuidTextField.resignFirstResponder()
        majorTextField.resignFirstResponder()
        minorTextField.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func displayName(){
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
                    //print (snapshot)
                    print (auth)
                    //print (user.name)
                    let value = snapshot.value as? NSDictionary
                    let uname = value?["name"] as! String ?? "Lolmax"
                    let cdsid = value?["cdsid"] as! String ?? "Lolmax"
                    self.display.text = "Welcome \(uname)"
                    self.display.isHidden = false
                }, withCancel: nil)
            }
            else{
                //Do nothing
                print ("no user logged in")
            }
        }
    }
    
    @IBAction func signOutBtn(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            //move to the register screen
        }
        catch let err {
            print (err)
        }
        
        //move to
    }

}

extension SweetHomeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem = doneButton
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let defaults = UserDefaults.standard
        if textField == uuidTextField && !textField.text!.isEmpty {
            defaults.set(textField.text, forKey: kUUIDKey)
        }
        else if textField == majorTextField && !textField.text!.isEmpty {
            defaults.set(textField.text, forKey: kMajorIdKey)
        }
        else if textField == minorTextField && !textField.text!.isEmpty {
            defaults.set(textField.text, forKey: kMinorIdKey)
        }
        
    }
}

extension SweetHomeViewController: RegionMonitorDelegate {
    func didStartMonitoring() {
        isMonitoring = true
    }
    
    func didStopMonitoring() {
        isMonitoring = false
    }
    
    func onBackgroundLocationAccessDisabled() {
        let alertController = UIAlertController(
            title: NSLocalizedString("regmon.alert.title.location-access-disabled", comment: "foo"), message: NSLocalizedString("regmon.alert.message.location-access-disabled", comment: "foo"),
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(
            UIAlertAction(title: "Settings", style: .default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                } })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func toggleMonitoring() {
        if isMonitoring {
            regionMonitor.stopMonitoring()
        } else {
            if uuidTextField.text!.isEmpty {
                print("Please provide a valid UUID")
                return
            }
            regionIdLabel.text = ""
            proximityLabel.text = ""
            distanceLabel.text = ""
            rssiLabel.text = ""
            if let uuid = NSUUID(uuidString: uuidTextField.text!) {
                let identifier = "my.beacon"
                var beaconRegion: CLBeaconRegion?
                if let major = Int(majorTextField.text!) {
                    if let minor = Int(minorTextField.text!) {
                        beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, major:
                            CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor),
                                                       identifier: identifier)
                    } else {
                        beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID,
                                                      major: CLBeaconMajorValue(major), identifier: identifier)
                    }
                } else {
                    beaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: identifier)
                }
                // later, these values can be set from the UI
                beaconRegion!.notifyEntryStateOnDisplay = true
                beaconRegion!.notifyOnEntry = true
                beaconRegion!.notifyOnExit = true
                regionMonitor.startMonitoring(beaconRegion: beaconRegion)
            } else {
                let alertController = UIAlertController(title:"iBeaconApp", message: "Please enter a valid UUID", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default,
                                                        handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } }
    }
    
    
    func didRangeBeacon(beacon: CLBeacon!, region: CLRegion!) {
        regionIdLabel.text = region.identifier
        proximityLabel.text = "\(beacon.proximityUUID)"
        print("\(beacon.major)")
        print("\(beacon.minor)")
        switch (beacon.proximity) {
        case CLProximity.far:
            print("Far")
        case CLProximity.near:
            print("Near")
        case CLProximity.immediate:
            print("Immediate")
        case CLProximity.unknown:
            print("unknown")
        }
        distanceLabel.text = distanceFormatter.string(fromMeters: beacon.accuracy)
        rssiLabel.text = "\(beacon.rssi)"
        regionMonitor.stopMonitoring()
    }
    
    func didEnterRegion(region: CLRegion!) {
        print("Entered Region")
        view.backgroundColor = UIColor.init(red: 163/255, green: 255/255, blue: 155/255, alpha: 1)
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid as! UUID, major:
            CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor),
                                       identifier: identifier)
        regionMonitor.startRanging(beaconRegion: beaconRegion)
    }
    func didExitRegion(region: CLRegion!) {
        view.backgroundColor = .white
        print("Exited region")

    }
    
    func onError(error: NSError) {
        print(error)
    }
}
