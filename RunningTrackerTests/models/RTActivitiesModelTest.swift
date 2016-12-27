//
//  RTActivitiesModelTest.swift
//  RunningTracker
//
//  Created by MIGUEL MOLDES on 17/7/16.
//  Copyright © 2016 MIGUEL MOLDES. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import PromiseKit

@testable import RunningTracker

class RTActivitiesModelTest:XCTestCase{

    static let ArchiveURLTest = RTActivitiesModel.DocumentsDirectory.appendingPathComponent("activitiesTest")
    
    var model:RTActivitiesModelFake!
    var storeManager : RTSoreManagerFake!
    
    override func setUp() {
        super.setUp()
        model = RTActivitiesModelFake()
        storeManager = RTSoreManagerFake()
    }
    
    override func tearDown() {
        model.deleteAllActivities()
        _ = model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path, storeManager: storeManager)
        model.valuesRefreshed = false
        storeManager = nil
        super.tearDown()
    }
    
    func testStartActivity() {
        XCTAssertEqual(model.activitiesLength(), 0)
        XCTAssertTrue(!model.isCurrentActivityDefined(), "currentActivity shouldn't be defined")
        model.tryStartActivity()

        XCTAssertTrue(model.isCurrentActivityDefined(), "currentActivity should be defined")
        do{
            try model.startActivity()
            XCTAssertTrue(false, "it shouldn't be possible to start a new activity")
        } catch {}

        XCTAssertTrue(model.activityRunning, "activityRunning should be true")
        XCTAssertEqual(model.activitiesLength(), 0)
    }

    func testEndActivity() {
        XCTAssertFalse(model.endActivity(), "you cannot end an activity when there is none active")
        let now = Date().timeIntervalSince1970
        model.fakeNow = now
        model.tryStartActivity()
        _ = model.addLocationToCurrentActivity()
        let location2 = model.mockActivityLocation(now + 11, lat:12.55560, long:14)
        _ = model.addActivityLocation(location2)
        XCTAssertTrue(model.activityRunning, "activityRunning should be true")

        _ = model.endActivity()

        XCTAssertEqual(model.activitiesLength(), 1)
        XCTAssertFalse(model.activityRunning, "activityRunning should be false")
        XCTAssertFalse(model.isCurrentActivityDefined(), "current activity should not be defined")
        XCTAssertTrue(model.valuesRefreshed)
    }

    func testResumeActivity() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now
        model.tryStartActivity()
        model.fakeNow = now + 5
        model.pauseActivity()
        model.fakeNow = now + 10
        model.resumeActivity()

        XCTAssertEqual(model.currentActivityCopy()!.pausedTime, 5)
    }

    func testSaveActivities() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now
        XCTAssertEqual(model.activitiesLength(), 0)
        XCTAssertFalse(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path, storeManager: storeManager))
        model.mockActivityWithTwoLocations()

        let sub = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "activitiesSaved"), object: nil, queue: nil) { (not) -> Void in
            XCTAssertEqual(self.model.activitiesLength(), 1)
        }
        expectation(forNotification: "activitiesSaved", object: nil, handler: nil)
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path, storeManager: storeManager))
        waitForExpectations(timeout: 1.0, handler: nil)

        NotificationCenter.default.removeObserver(sub)
    }

    func testLoadActivities() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now
        XCTAssertEqual(model.activitiesLength(), 0)
        model.mockActivityWithTwoLocations()

        let sub = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "activitiesSaved"), object: nil, queue: nil) { (not) -> Void in
            self.expectation(forNotification: "activitiesLoaded", object: nil, handler: nil)
            self.model.loadActivities(RTActivitiesModelTest.ArchiveURLTest.path, storeManager: self.storeManager)

            self.waitForExpectations(timeout: 0.1, handler: nil)
        }

        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path, storeManager: storeManager))

        NotificationCenter.default.removeObserver(sub)
    }

    func testRefreshValues() {
        XCTAssertFalse(model.currentActivityPaused, "activity should not be paused")
        XCTAssertFalse(model.currentActivityJustResumed, "activity should not be just resumed")
        XCTAssertEqual(model.currentActivityPausedAt, 0)
    }

    func testAddActivityLocation() {
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)

        XCTAssertFalse(model.addActivityLocation(activityLocation!), "current activity is not set yet")

        model.tryStartActivity()

        model.pauseActivity()
        XCTAssertFalse(model.addActivityLocation(activityLocation!))

        model.resumeActivity()
        XCTAssertTrue(model.addActivityLocation(activityLocation!))
        XCTAssertTrue(activityLocation!.firstAfterResumed)

        let location2 = CLLocation(latitude:221.22, longitude: 3322.3)
        let activityLocation2 : RTActivityLocation? = RTActivityLocation(location: location2, timestamp: 100)
        XCTAssertTrue(model.addActivityLocation(activityLocation2!))
        XCTAssertFalse(activityLocation2!.firstAfterResumed)

        XCTAssertEqual(model.currentActivityCopy()!.getActivitiesCopy().count, 2)
    }

    func testCurrentActivityLocations() {
        model.tryStartActivity()
        let activity = model.currentActivityCopy()
        var locations:[RTActivityLocation] = activity!.getActivitiesCopy()
        XCTAssertEqual(locations.count, 0)
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)
        _ = model.addActivityLocation(activityLocation!)

        locations = model.currentActivityCopy()!.getActivitiesCopy()

        XCTAssertEqual(locations.count, 1)
    }

    func testGetElapsedTime() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now

        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }

        model.fakeNow = now + 5
        model.pauseActivity()

        model.fakeNow = now + 10
        model.resumeActivity()

        model.fakeNow = now + 15
        let result = model.getElapsedTime()
        XCTAssertEqual(result, 10)

        model.fakeNow = now + 100
        XCTAssertEqual(model.getElapsedTime(), 95)
    }

    func testGetDistanceDone() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now

        model.tryStartActivity()

        let location1 = model.mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = model.mockActivityLocation(now + 15, lat:12.55560, long:13)
        _ = model.addActivityLocation(location1)
        _ = model.addActivityLocation(location2)

        let distance : Double = 5.531338377508936
        XCTAssertEqual(model.getDistanceDone(), distance)
    }

    func testGetPaceLastKM() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now

        model.tryStartActivity()

        let location1 = model.mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = model.mockActivityLocation(now + 15, lat:12.55560, long:13)
        _ = model.addActivityLocation(location1)
        _ = model.addActivityLocation(location2)

        let distance : Double = 5.531338377508936
        XCTAssertEqual(location2.distance, distance)

        let pace = 1000 * 5 / distance
        XCTAssertEqual(model.getPaceLastKM(), pace)
    }

    func testPauseActivity() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now
        model.tryStartActivity()

        model.fakeNow = now + 5
        model.pauseActivity()

        XCTAssertEqual(model.currentActivityPausedAt, now + 5)
        XCTAssertTrue(model.currentActivityPaused)
    }

    func testGetBestPace() {

        var now = Date().timeIntervalSince1970
        model.fakeNow = now

        model.tryStartActivity()

        let location1 = model.mockActivityLocation(now, lat:12.55555, long:13)
        let location2 = model.mockActivityLocation(now + 15, lat:12.55560, long:13)
        _ = model.addActivityLocation(location1)
        _ = model.addActivityLocation(location2)

        model.fakeNow = now + 15
        _ = model.endActivity()

        now = now + 20
        model.fakeNow = now

        model.tryStartActivity()

        let location3 = model.mockActivityLocation(now, lat:12.55555, long:13)
        let location4 = model.mockActivityLocation(now + 11, lat:12.55560, long:13)
        _ = model.addActivityLocation(location3)
        _ = model.addActivityLocation(location4)

        let pace2 = model.getPaceLastKM()
        model.fakeNow = now + 11
        _ = model.endActivity()

        let pace : Double = model.getBestPace()
        XCTAssertEqual(pace, pace2)
    }

    func testGetLongestDistance() {

        var now = Date().timeIntervalSince1970
        model.fakeNow = now

        model.tryStartActivity()

        let location1 = model.mockActivityLocation(now, lat:12.55555, long:13)
        let location2 = model.mockActivityLocation(now + 15, lat:12.55560, long:13)
        _ = model.addActivityLocation(location1)
        _ = model.addActivityLocation(location2)

        model.fakeNow = now + 15
        _ = model.endActivity()

        now = now + 20
        model.fakeNow = now

        model.tryStartActivity()

        let location3 = model.mockActivityLocation(now, lat:12.55555, long:13)
        let location4 = model.mockActivityLocation(now + 11, lat:12.55600, long:13)
        _ = model.addActivityLocation(location3)
        _ = model.addActivityLocation(location4)

        let distance2 = location4.distance
        model.fakeNow = now + 11
        _ = model.endActivity()

        let distance = model.getLongestDistance()
        XCTAssertEqual(distance, distance2)

    }

    func testActivitiesLenght() {
        XCTAssertEqual(model.activitiesLength(), 0)
        model.tryStartActivity()
        _ = model.endActivity()
        XCTAssertEqual(model.activitiesLength(), 0)

        let now = Date().timeIntervalSince1970
        model.fakeNow = now
        model.tryStartActivity()
        let location1 = model.mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = model.mockActivityLocation(now + 15, lat:12.55555, long:14)
        _ = model.addActivityLocation(location1)
        _ = model.addActivityLocation(location2)
        _ = model.endActivity()
        XCTAssertEqual(model.activitiesLength(), 1)

    }

    func testGetActivities() {
        let now = Date().timeIntervalSince1970
        model.fakeNow = now

        let location1 = model.mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = model.mockActivityLocation(now + 11, lat:12.55560, long:14)

        model.tryStartActivity()
        _ = model.addActivityLocation(location1)
        _ = model.addActivityLocation(location2)
        _ = model.endActivity()
        model.fakeNow = now + 20
        let location3 = model.mockActivityLocation(now, lat:12.55560, long:13)
        let location4 = model.mockActivityLocation(now, lat:12.55565, long:15)
        model.tryStartActivity()
        _ = model.addActivityLocation(location3)
        _ = model.addActivityLocation(location4)
        _ = model.endActivity()
        let activities = model.activitiesCopy()
        XCTAssertEqual(2, activities.count)
        XCTAssertEqual(activities[0].startTime, now)
        XCTAssertEqual(activities[1].startTime, now + 20)
    }

}