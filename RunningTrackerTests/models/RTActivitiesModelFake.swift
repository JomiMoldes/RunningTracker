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
    var activitiesSaved:Bool = false

    var fakeNow:TimeInterval = Date().timeIntervalSince1970
    let storeManagerFake = RTSoreManagerFake()

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

    override func saveActivities(_ path: String, storeManager: RTStoreActivitiesManager) -> Bool {
        activitiesSaved = true
        return super.saveActivities(path, storeManager: self.storeManagerFake)
    }

    override func deleteActivity(_ activityToDelete:RTActivity, storeManager: RTStoreActivitiesManager) {
        super.deleteActivity(activityToDelete, storeManager: self.storeManagerFake)
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

    func mockActivityWithTwoLocations(_ withFinishing:Bool = true, _ gpsTickTime:Double = 10.0) {
        tryStartActivity()
        fakeNow = fakeNow + gpsTickTime
        let location1 = mockActivityLocation(fakeNow, lat:100.2, long:100.2)
        fakeNow = fakeNow + gpsTickTime
        let location2 = mockActivityLocation(fakeNow, lat:100.2005, long:100.2)
        _ = addActivityLocation(location1)
        _ = addActivityLocation(location2)
        fakeNow = fakeNow + gpsTickTime
        if withFinishing {
            _ = endActivity()
        }

    }

    func addLocationToCurrentActivity() -> RTActivityLocation? {
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)
        _ = addActivityLocation(activityLocation!)
        return activityLocation
    }

    func fakeActivity() -> RTActivity {
        mockActivityWithTwoLocations()
        return currentActivityCopy()!
    }

}
