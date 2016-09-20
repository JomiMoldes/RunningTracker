//
// Created by MIGUEL MOLDES on 28/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import RunningTracker

class RTActivityTest : XCTestCase {

    var activity : RTActivity!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        self.activity = nil
        super.tearDown()
    }

    func testInit() {
        let now = NSDate().timeIntervalSince1970
        let locations : [RTActivityLocation] = []

        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())
        XCTAssertEqual(self.activity.finishTime, 0.00)

    }

    func testInitWithActivities() {
        let now = NSDate().timeIntervalSince1970
        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        let location3 = mockActivityLocation(now + 20, lat:12.55565, long:13)
        let locations : [RTActivityLocation] = [location1, location2, location3]

        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())

        let activities = self.activity.getActivitiesCopy()
        XCTAssertEqual(activities.count, 3)
        let actitivyLocation1 = activities[0]
        let actitivyLocation2 = activities[1]
        let actitivyLocation3 = activities[2]
        XCTAssertTrue(self.compareLocations(actitivyLocation1, location2:location1))
        XCTAssertTrue(self.compareLocations(actitivyLocation2, location2:location2))
        XCTAssertTrue(self.compareLocations(actitivyLocation3, location2:location3))
    }

    func compareLocations(location1:RTActivityLocation, location2:RTActivityLocation) -> Bool {
        if location1.timestamp == location2.timestamp &&
                location1.distance == location2.distance &&
                location1.firstAfterResumed == location2.firstAfterResumed &&
                location1.location.coordinate.latitude == location2.location.coordinate.latitude &&
                location1.location.coordinate.longitude == location2.location.coordinate.longitude {
            return true
        }
        return false
    }

    func testAddActivityLocation() {
        let now = NSDate().timeIntervalSince1970
        let locations : [RTActivityLocation] = []
        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())
        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        XCTAssertEqual(self.activity.getActivitiesCopy().count, 0)
        self.activity.addActivityLocation(location1, checkMarkers:false)
        XCTAssertEqual(self.activity.getActivitiesCopy().count, 1)

        let coords2 = CLLocation(coordinate:CLLocationCoordinate2DMake(CLLocationDegrees(12.55560), CLLocationDegrees(13)), altitude: 10.0, horizontalAccuracy: 50, verticalAccuracy: 50, timestamp: NSDate())
        let location2 : RTActivityLocation? = RTActivityLocation(location: coords2, timestamp: now)
    
        XCTAssertFalse(self.activity.addActivityLocation(location2!, checkMarkers:false), "Horizontal accuracy is too big")

        let coords3 = CLLocation(coordinate:CLLocationCoordinate2DMake(CLLocationDegrees(12.55560), CLLocationDegrees(13)), altitude: 10.0, horizontalAccuracy: 5, verticalAccuracy: 50, timestamp: NSDate())
        let location3 : RTActivityLocation? = RTActivityLocation(location: coords3, timestamp: now)

        XCTAssertTrue(self.activity.addActivityLocation(location3!, checkMarkers:false))
        
        let location4 : RTActivityLocation? = RTActivityLocation(location: coords3, timestamp: now)

        XCTAssertFalse(self.activity.addActivityLocation(location4!, checkMarkers:false), "last activity recorded has the same coords")
    }

    func testActivityFinished() {
        let now = NSDate().timeIntervalSince1970
        let locations : [RTActivityLocation] = []
        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())
        self.activity.activityFinished(now + 5)
        XCTAssertEqual(self.activity.finishTime, now + 5)
    }

    func testGetDuration() {
        let now = NSDate().timeIntervalSince1970
        let locations : [RTActivityLocation] = []
        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())
        self.activity.pausedTime = 5
        self.activity.activityFinished(now + 10)
        XCTAssertEqual(self.activity.getDuration(), 5)
    }

    func testGetPace() {
        let now = NSDate().timeIntervalSince1970
        let locations : [RTActivityLocation] = []
        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())
        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        self.activity.addActivityLocation(location1, checkMarkers:false)
        self.activity.addActivityLocation(location2, checkMarkers:false)

        let distance : Double = location2.location.distanceFromLocation(location1.location)
        let totalTime : Double = 20
        let pace = 1000 * totalTime / distance

        XCTAssertEqual(self.activity.getPace(), 0)

        self.activity.activityFinished(now + 20)
        XCTAssertEqual(self.activity.getPace(), pace)
    }

    func testDistance() {
        let now = NSDate().timeIntervalSince1970
        let locations : [RTActivityLocation] = []
        self.activity = RTActivity(activities:locations, startTime: now, finishTime: 0.00, pausedTime2: 0.00, distance: 0, locationsAfterResumed: [CLLocation]())
        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        self.activity.addActivityLocation(location1, checkMarkers:false)
        self.activity.addActivityLocation(location2, checkMarkers:false)

        let distance : Double = location2.location.distanceFromLocation(location1.location)
        XCTAssertEqual(self.activity.distance, distance)
        XCTAssertEqual(location1.distance, 0)
        XCTAssertEqual(location2.distance, distance)
    }

    func mockActivityLocation(now:NSTimeInterval, lat:Double = 111.22, long:Double = 333.3) -> RTActivityLocation {
        let location = CLLocation(latitude:lat, longitude: long)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: now)
        return activityLocation!
    }

}
