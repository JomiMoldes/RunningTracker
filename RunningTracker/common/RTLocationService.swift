//
// Created by MIGUEL MOLDES on 21/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol RTLocationServiceDelegate : class {

    @objc optional func shouldChangePermissions()
    @objc optional func didUpdateLocation(location:CLLocation)
    @objc optional func didFail()

}

class RTLocationService : NSObject, RTLocationServiceProtocol {

    weak var delegate : RTLocationServiceDelegate?

    let locationMgr = CLLocationManager()
    var requested = false
    var started = false

    override init() {
        super.init()
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationMgr.distanceFilter = 20.0
        locationMgr.activityType = CLActivityType.fitness
        locationMgr.allowsBackgroundLocationUpdates = true
        locationMgr.pausesLocationUpdatesAutomatically = false
    }

    func requestPermissions() {
        let status = getLocationStatus()
        switch (status){
            case .notDetermined:
                self.askForWhenInUseAuthorization()
                break
            case .authorizedAlways, .restricted, .denied:
                self.delegate?.shouldChangePermissions?()
                break
            default:
                break
        }
    }

    func getLocationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    private func askForWhenInUseAuthorization() {
        locationMgr.requestWhenInUseAuthorization()
        requested = true
    }

    fileprivate func startUpdating() {
        locationMgr.startUpdatingLocation()
        started = true
    }

}

extension RTLocationService : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            self.startUpdating()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations[locations.count - 1]
        self.delegate?.didUpdateLocation?(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        self.delegate?.didFail?()
        if(getLocationStatus() == .authorizedWhenInUse){
            self.startUpdating()
        }
    }

}