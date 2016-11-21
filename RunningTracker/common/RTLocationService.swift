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

class RTLocationService : NSObject {

    weak var delegate : RTLocationServiceDelegate?

    private let locationManager  = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 20.0
        locationManager.activityType = CLActivityType.fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func requestPermissions() {
        switch (CLLocationManager.authorizationStatus()){
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedAlways, .restricted, .denied:
                self.delegate?.shouldChangePermissions?()
                break
            default:
                break
        }
    }

}

extension RTLocationService : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations[locations.count - 1]
        self.delegate?.didUpdateLocation?(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        self.delegate?.didFail?()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
            manager.startUpdatingLocation()
        }
    }

}


