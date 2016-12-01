//
// Created by MIGUEL MOLDES on 1/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

@testable import RunningTracker

class RTActiveMapViewModelFake : RTActiveMapViewModel {

    var locationStarted = false
    var timerStarted = false
    var observersRemoved = false

    override func startLocation() {
        super.startLocation()
        locationStarted = true
    }

    override func setupTimer() {
        super.setupTimer()
        timerStarted = true
    }

    override func removeObservers() {
        super.removeObservers()
        observersRemoved = true
    }


}
