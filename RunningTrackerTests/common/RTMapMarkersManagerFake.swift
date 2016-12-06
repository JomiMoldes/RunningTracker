//
// Created by MIGUEL MOLDES on 6/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation
import XCTest

@testable import RunningTracker

class RTMapMarkersManagerFake : RTMapMarkersManager {

    var endFlagExpectation: XCTestExpectation?
    var activityDrawn : RTActivity?
    var checkMarksToDraw  : [Int:CLLocation]?

    override func drawPath(_ activity: RTActivity) {
        activityDrawn = activity
        super.drawPath(activity)
    }

    override func redrawMarkers(_ markers: [Int: CLLocation]) {
        checkMarksToDraw = markers
        super.redrawMarkers(markers)
    }

    override func addMarkerWithLocation(_ location: CLLocation, km: Int, markImage: UIImage?) {
        super.addMarkerWithLocation(location, km: km, markImage: markImage)
        guard let endFlagExpectation = endFlagExpectation else {
            return
        }
        if km == -1 {
            endFlagExpectation.fulfill()
        }
    }


}
