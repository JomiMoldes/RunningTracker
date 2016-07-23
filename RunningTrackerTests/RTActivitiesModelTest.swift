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
@testable import RunningTracker

class RTActivitiesModelTest:XCTestCase{

    static let ArchiveURLTest = RTActivitiesModel.DocumentsDirectory.URLByAppendingPathComponent("activitiesTest")
    
    var model:RTActivitiesModelFake!
    
    override func setUp() {
        super.setUp()
        model = RTActivitiesModelFake()
    }
    
    override func tearDown() {
        model.deleteAllActivities()
        model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!)
        model.valuesRefreshed = false
        super.tearDown()
    }
    
    func testStartActivity() {
        XCTAssertEqual(model.activitiesLenght(), 0)
        XCTAssertTrue(!model.isCurrentActivityDefined(), "currentActivity shouldn't be defined")
        mockStartActivity()

        XCTAssertTrue(model.isCurrentActivityDefined(), "currentActivity should be defined")
        do{
            try model.startActivity()
            XCTAssertTrue(false, "it shouldn't be possible to start a new activity")
        } catch {}

        XCTAssertTrue(model.activityRunning, "activityRunning should be true")
        XCTAssertEqual(model.activitiesLenght(), 0)
    }

    func testEndActivity() {
        XCTAssertFalse(model.endActivity(), "you cannot end an activity when there is none active")
        mockStartActivity()

        XCTAssertTrue(model.activityRunning, "activityRunning should be true")
        model.endActivity()

        XCTAssertEqual(model.activitiesLenght(), 1)
        XCTAssertFalse(model.activityRunning, "activityRunning should be true")
        XCTAssertFalse(model.isCurrentActivityDefined(), "current activity should not be defined")
        XCTAssertTrue(model.valuesRefreshed)
    }

    func testResumeActivity() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now
        mockStartActivity()
        model.fakeNow = now + 5
        model.pauseActivity()
        model.fakeNow = now + 10
        model.resumeActivity()

        XCTAssertEqual(model.getCurrentActivityPausedTime(), 5)
    }

    func testSaveActivities() {
        XCTAssertEqual(model.activitiesLenght(), 0)
        mockStartActivity()
        model.endActivity()
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!))
    }

    func testLoadActivities() {
        XCTAssertEqual(model.activitiesLenght(), 0)
        mockStartActivity()
        model.endActivity()
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!))
        model.loadActivities(RTActivitiesModelTest.ArchiveURLTest.path!)
        XCTAssertEqual(model.activitiesLenght(), 1)
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

        mockStartActivity()

        model.pauseActivity()
        XCTAssertFalse(model.addActivityLocation(activityLocation!))

        model.resumeActivity()
        XCTAssertTrue(model.addActivityLocation(activityLocation!))
        XCTAssertTrue(activityLocation!.firstAfterResumed)

        let location2 = CLLocation(latitude:221.22, longitude: 3322.3)
        let activityLocation2 : RTActivityLocation? = RTActivityLocation(location: location2, timestamp: 100)
        XCTAssertTrue(model.addActivityLocation(activityLocation2!))
        XCTAssertFalse(activityLocation2!.firstAfterResumed)

        XCTAssertEqual(model.currentActivitesLocationsLenght(), 2)
    }

    func testCurrentActivityLocations() {
        mockStartActivity()
        var locations:[RTActivityLocation] = model.currentActivityLocations()
        XCTAssertEqual(locations.count, 0)
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)
        model.addActivityLocation(activityLocation!)
        
        locations = model.currentActivityLocations()
        
        XCTAssertEqual(locations.count, 1)
    }

    func testGetElapsedTime() {
        let now = NSDate().timeIntervalSince1970
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

    func testGetPaceLastKM() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now

        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }

        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        model.addActivityLocation(location1)
        model.addActivityLocation(location2)

        let distance : Double = 5.5313383877970717
        XCTAssertEqual(location2.distance, distance)

        let pace = 1000 * 5 / distance
        XCTAssertEqual(model.getPaceLastKM(), pace)
    }

    func mockStartActivity() {
        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }
    }

    func mockActivityLocation(now:NSTimeInterval, lat:Double = 111.22, long:Double = 333.3) -> RTActivityLocation {
        let location = CLLocation(latitude:lat, longitude: long)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: now)
        return activityLocation!
    }

}

class RTActivitiesModelFake:RTActivitiesModel{

    var valuesRefreshed:Bool = false

    var fakeNow:NSTimeInterval = NSDate().timeIntervalSince1970
    
    override init() {
        super.init()
    }

    override func refreshValues() {
        valuesRefreshed = true
        super.refreshValues()
    }

    override func getNow() -> NSTimeInterval {
        return fakeNow
    }

}


