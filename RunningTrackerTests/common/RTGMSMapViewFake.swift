//
// Created by MIGUEL MOLDES on 6/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import GoogleMaps
import XCTest

class RTGMSMapViewFake : GMSMapView {

    var animated : Bool = false
    var clearExpectation : XCTestExpectation?

    override open func animate(toLocation location: CLLocationCoordinate2D) {
        animated = true
        super.animate(toLocation:location)
    }

    override func clear() {
        super.clear()
        clearExpectation?.fulfill()
    }


}
