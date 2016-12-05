//
// Created by MIGUEL MOLDES on 1/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import GoogleMaps

@testable import RunningTracker

class RTActiveMapViewModelFake : RTActiveMapViewModel {

    var locationStarted = false
    var timerStarted = false
    var observersRemoved = false
    var mapViewAsyncExpectation:XCTestExpectation?

    override func startLocation() {
        super.startLocation()
        locationStarted = true
    }

    override func setupTimer() {
//        super.setupTimer()
        timerStarted = true
    }

    override func removeObservers() {
        super.removeObservers()
        observersRemoved = true
    }

    override func getSavingPath() -> String {
        return RTActivitiesModelTest.ArchiveURLTest.path
    }

    override func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        super.mapView(mapView, didChange: position)
        DispatchQueue.main.async {
            self.mapViewAsyncExpectation?.fulfill()

        }

    }


}
