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
    var storeManager : RTSoreManagerFake!
    
    override func setUp() {
        super.setUp()
        model = RTActivitiesModelFake()
        storeManager = RTSoreManagerFake()
    }
    
    override func tearDown() {
        model.deleteAllActivities()
        model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!, storeManager: storeManager)
        model.valuesRefreshed = false
        storeManager = nil
        super.tearDown()
    }
    
    func testStartActivity() {
        XCTAssertEqual(model.activitiesLength(), 0)
        XCTAssertTrue(!model.isCurrentActivityDefined(), "currentActivity shouldn't be defined")
        mockStartActivity()

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
        mockStartActivity()
        addLocationToCurrentActivity()

        XCTAssertTrue(model.activityRunning, "activityRunning should be true")
        model.endActivity()

        XCTAssertEqual(model.activitiesLength(), 1)
        XCTAssertFalse(model.activityRunning, "activityRunning should be false")
        XCTAssertFalse(model.isCurrentActivityDefined(), "current activity should not be defined")
        XCTAssertTrue(model.valuesRefreshed)
    }
    
    func addLocationToCurrentActivity() {
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)
        model.addActivityLocation(activityLocation!)
    }

    func testResumeActivity() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now
        mockStartActivity()
        model.fakeNow = now + 5
        model.pauseActivity()
        model.fakeNow = now + 10
        model.resumeActivity()

        XCTAssertEqual(model.getCurrentActivityCopy()!.pausedTime, 5)

    }

    func testSaveActivities() {
        XCTAssertEqual(model.activitiesLength(), 0)
        XCTAssertFalse(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!, storeManager: storeManager))
        mockStartActivity()
        addLocationToCurrentActivity()
        model.endActivity()
        
        let sub = NSNotificationCenter.defaultCenter().addObserverForName("activitiesSaved", object: nil, queue: nil) { (not) -> Void in
            XCTAssertEqual(self.model.activitiesLength(), 0)
        }
        expectationForNotification("activitiesSaved", object: nil, handler: nil)
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!, storeManager: storeManager))
        waitForExpectationsWithTimeout(0.1, handler: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(sub)
    }

    func testLoadActivities() {
        XCTAssertEqual(model.activitiesLength(), 0)
        mockStartActivity()
        addLocationToCurrentActivity()
        model.endActivity()
        
        let sub = NSNotificationCenter.defaultCenter().addObserverForName("activitiesSaved", object: nil, queue: nil) { (not) -> Void in
            self.expectationForNotification("activitiesLoaded", object: nil, handler: nil)
            self.model.loadActivities(RTActivitiesModelTest.ArchiveURLTest.path!, storeManager: self.storeManager)
            
            self.waitForExpectationsWithTimeout(0.1, handler: nil)
        }        
        
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!, storeManager: storeManager))
        
        NSNotificationCenter.defaultCenter().removeObserver(sub)
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

        XCTAssertEqual(model.getCurrentActivityCopy()!.getActivitiesCopy().count, 2)
    }

    func testCurrentActivityLocations() {
        mockStartActivity()
        let activity = model.getCurrentActivityCopy()
        var locations:[RTActivityLocation] = activity!.getActivitiesCopy()
        XCTAssertEqual(locations.count, 0)
        let location = CLLocation(latitude:1111.22, longitude: 3333.3)
        let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: 100)
        model.addActivityLocation(activityLocation!)
        
        locations = model.getCurrentActivityCopy()!.getActivitiesCopy()

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

    func testGetDistanceDone() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now

        mockStartActivity()

        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        model.addActivityLocation(location1)
        model.addActivityLocation(location2)

        let distance : Double = 5.5313383877970717
        XCTAssertEqual(model.getDistanceDone(), distance)
    }

    func testGetPaceLastKM() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now

        mockStartActivity()

        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        model.addActivityLocation(location1)
        model.addActivityLocation(location2)

        let distance : Double = 5.5313383877970717
        XCTAssertEqual(location2.distance, distance)

        let pace = 1000 * 5 / distance
        XCTAssertEqual(model.getPaceLastKM(), pace)
    }

    func testPauseActivity() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now
        mockStartActivity()
        
        model.fakeNow = now + 5
        model.pauseActivity()

        XCTAssertEqual(model.currentActivityPausedAt, now + 5)
        XCTAssertTrue(model.currentActivityPaused)
    }

    func testGetBestPace() {

        var now = NSDate().timeIntervalSince1970
        model.fakeNow = now

        mockStartActivity()

        let location1 = mockActivityLocation(now, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        model.addActivityLocation(location1)
        model.addActivityLocation(location2)

        let pace1 = model.getPaceLastKM()
        model.fakeNow = now + 15
        model.endActivity()

        now = now + 20
        model.fakeNow = now

        mockStartActivity()

        let location3 = mockActivityLocation(now, lat:12.55555, long:13)
        let location4 = mockActivityLocation(now + 11, lat:12.55560, long:13)
        model.addActivityLocation(location3)
        model.addActivityLocation(location4)

        let pace2 = model.getPaceLastKM()
        model.fakeNow = now + 11
        model.endActivity()

        let pace : Double = model.getBestPace()
        XCTAssertEqual(pace, pace2)
    }

    func testGetLongestDistance() {

        var now = NSDate().timeIntervalSince1970
        model.fakeNow = now

        mockStartActivity()

        let location1 = mockActivityLocation(now, lat:12.55555, long:13)
        let location2 = mockActivityLocation(now + 15, lat:12.55560, long:13)
        model.addActivityLocation(location1)
        model.addActivityLocation(location2)

        let distance1 = location2.distance
        model.fakeNow = now + 15
        model.endActivity()

        now = now + 20
        model.fakeNow = now

        mockStartActivity()

        let location3 = mockActivityLocation(now, lat:12.55555, long:13)
        let location4 = mockActivityLocation(now + 11, lat:12.55600, long:13)
        model.addActivityLocation(location3)
        model.addActivityLocation(location4)

        let distance2 = location4.distance
        model.fakeNow = now + 11
        model.endActivity()

        let distance = model.getLongestDistance()
        XCTAssertEqual(distance, distance2)

    }

    func testActivitiesLenght() {
        XCTAssertEqual(model.activitiesLength(), 0)
        mockStartActivity()
        model.endActivity()
        XCTAssertEqual(model.activitiesLength(), 0)
        
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now
        mockStartActivity()
        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)
        model.addActivityLocation(location1)
        model.endActivity()
        XCTAssertEqual(model.activitiesLength(), 1)
        
    }

    func testGetActivities() {
        let now = NSDate().timeIntervalSince1970
        model.fakeNow = now
        
        let location1 = mockActivityLocation(now + 10, lat:12.55555, long:13)

        mockStartActivity()
        model.addActivityLocation(location1)
        model.endActivity()
        model.fakeNow = now + 20
        let location2 = mockActivityLocation(now, lat:12.55560, long:13)
        mockStartActivity()
        model.addActivityLocation(location2)
        model.endActivity()
        let activities = model.getActivitiesCopy()
        XCTAssertEqual(2, activities.count)
        XCTAssertEqual(activities[0].startTime, now)
        XCTAssertEqual(activities[1].startTime, now + 20)
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

class RTSoreManagerFake:RTStoreActivitiesManager {
    
    override func start(path: String, completion: ([RTActivity]) -> Void) -> Bool {
        completion([RTActivity]())
        return true
    }
    
    override func saveActivities(activities: [RTActivity], completion: ([RTActivity]) -> Void) {
        completion([RTActivity]())
    }
}

class RTActivityFake:RTActivity {

    var fakePace = 0.0

    override func getPace() -> Double {
        return fakePace
    }

}


