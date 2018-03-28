//
//  RegionMonitor.swift
//  Pico
//
//  Created by fordlabs on 14/03/18.
//  Copyright © 2018 ford. All rights reserved.
//

import Foundation
import CoreLocation

protocol RegionMonitorDelegate: NSObjectProtocol {
    func onBackgroundLocationAccessDisabled()
    func didStartMonitoring()
    func didStopMonitoring()
    func didEnterRegion(region: CLRegion!)
    func didExitRegion(region: CLRegion!)
    func didRangeBeacon(beacon: CLBeacon!, region: CLRegion!)
    func onError(error: NSError)
}

class RegionMonitor: NSObject {
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion?
    
    var rangedBeacon: CLBeacon! = CLBeacon()
    var pendingMonitorRequest: Bool = false
    weak var delegate: RegionMonitorDelegate?
    
    init(delegate: RegionMonitorDelegate) {
        super.init()
        self.delegate = delegate
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
    }
    
    
    
    func startMonitoring(beaconRegion: CLBeaconRegion?) {
        print("Start monitoring")
        pendingMonitorRequest = true
        self.beaconRegion = beaconRegion
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied, .authorizedWhenInUse:
            delegate?.onBackgroundLocationAccessDisabled()
        case .authorizedAlways:
            locationManager!.requestState(for: beaconRegion!)
            locationManager!.startMonitoring(for: beaconRegion!)
            pendingMonitorRequest = false
        }
    }
    
    func startRanging(beaconRegion: CLBeaconRegion) {
        locationManager!.startRangingBeacons(in: beaconRegion)
    }

    
    func stopMonitoring() {
        print("Stop monitoring")
        pendingMonitorRequest = false
        locationManager.stopRangingBeacons(in: beaconRegion!)
        locationManager.stopMonitoring(for: beaconRegion!)
        locationManager.stopUpdatingLocation()
        beaconRegion = nil
        delegate?.didStopMonitoring()
    }
    
}

extension RegionMonitor: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus
        status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus \(status)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if pendingMonitorRequest {
                locationManager!.startMonitoring(for: beaconRegion!)
                pendingMonitorRequest = false
            }
            locationManager!.startUpdatingLocation()
        }
    }
    private func locationManager(manager: CLLocationManager, didStartMonitoringForRegion
        region: CLRegion) {
        print("didStartMonitoringForRegion \(region.identifier)")
        delegate?.didStartMonitoring()
        locationManager.requestState(for: region)
    }
    private func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState,
                                 forRegion region: CLRegion) {
        print("didDetermineState")
        if state == CLRegionState.inside {
            print(" - entered region \(region.identifier)")
            locationManager.startRangingBeacons(in: beaconRegion!)
        } else {
            print(" - exited region \(region.identifier)")
            locationManager.stopRangingBeacons(in: beaconRegion!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion - \(region.identifier)")
        let userLocation = locationManager.location!
        print("User Locatoin: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        delegate?.didEnterRegion(region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion - \(region.identifier)")
        delegate?.didExitRegion(region: region)
    }
    
    private func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon],
                                 inRegion region: CLBeaconRegion) {
        print("didRangeBeacons - \(region.identifier)")
        if beacons.count > 0 {
            rangedBeacon = beacons[0]
            delegate?.didRangeBeacon(beacon: rangedBeacon, region: region)
        }
        
    }
    
    private func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region:
        CLRegion?, withError error: NSError) {
        print("monitoringDidFailForRegion - \(error)")
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        if (error.code == CLError.denied.rawValue) {
            stopMonitoring()
        }
    }
}



