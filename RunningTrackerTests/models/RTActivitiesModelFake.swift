//
// Created by MIGUEL MOLDES on 23/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation
import PromiseKit
import XCTest
@testable import RunningTracker

class RTActivitiesModelFake:RTActivitiesModel{

    var valuesRefreshed:Bool = false

    var fakeNow:TimeInterval = Date().timeIntervalSince1970

    override init() {
        super.init()
    }

    override func refreshValues() {
        valuesRefreshed = true
        super.refreshValues()
    }

    override func getNow() -> TimeInterval {
        return fakeNow
    }

    func tryStartActivity() {
        do{
            try startActivity()
        } catch {
            XCTAssertTrue(false, "no possible to start activity")
        }
    }

    func mockActivityLocation(_ now:TimeInterval, lat:Double = 111.22, long:Double = 333.3) -> RTActivityLocation {
        let location = CLLocation(latitude:lat, longitude: long)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: now)
        return activityLocation!
    }

    func mockActivityWithTwoLocations(_ withFinishing:Bool = true) {
        tryStartActivity()
        fakeNow = fakeNow + 5
        let location1 = mockActivityLocation(fakeNow, lat:100.2, long:100.2)
        fakeNow = fakeNow + 10000
        let location2 = mockActivityLocation(fakeNow, lat:101.2, long:100.2)
        addActivityLocation(location1)
        addActivityLocation(location2)
        fakeNow = fakeNow + 10000
        if withFinishing {
            endActivity()
        }

    }

    func addLocationToCurrentActivity() {
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)
        _ = addActivityLocation(activityLocation!)
    }

}
