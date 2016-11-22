//
// Created by MIGUEL MOLDES on 13/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class RTInitialViewModel : NSObject {

    var gpsRunningVariable = Variable<Bool>(false)
    var distanceVariable = Variable<String>("")
    var paceVariable = Variable<String>("")
    var gpsImageVariable = Variable(UIImage())
    let disposable = DisposeBag()

    let model:RTActivitiesModel!
    var locationManager:RTLocationService? = RTLocationService()
    weak var permissionsDelegate : RTLocationServiceDelegate?

    init?(model:RTActivitiesModel){
        self.model = model
        super.init()
        self.setup()
    }

    private func setup() {
        self.distanceVariable.value = self.getDistance()
        self.paceVariable.value = self.getPace()

        _ = self.gpsRunningVariable.asObservable()
                .map ({
                    return $0 ? UIImage(named:"GPSgreen.png")! : UIImage(named:"GPSblack.png")!

                })
                .bindTo(self.gpsImageVariable)
    }

    func startLocation() {
        locationManager?.delegate = self
        locationManager?.requestPermissions()
    }

    private func getPace() -> String {
        let pace = self.model.getBestPace()
        return pace.getMinutes() + ":" + pace.getSeconds()
    }

    private func getDistance() -> String {
        let distance = self.model.getLongestDistance()
        return String(format:"%.2f km", distance / 1000)
    }

    func killLocation() {
        locationManager?.delegate = nil
        locationManager = nil
    }

}

extension RTInitialViewModel : RTLocationServiceDelegate {

    func didUpdateLocation(location:CLLocation) {
        if self.gpsRunningVariable.value == false {
            self.gpsRunningVariable.value = true
        }
    }

    func didFail() {
        self.gpsRunningVariable.value = false
    }

    func shouldChangePermissions() {
        self.permissionsDelegate?.shouldChangePermissions?()
    }

}
