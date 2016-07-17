//
//  RTActivitiesModelTest.swift
//  RunningTracker
//
//  Created by MIGUEL MOLDES on 17/7/16.
//  Copyright © 2016 MIGUEL MOLDES. All rights reserved.
//

import XCTest
import Foundation
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
        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }
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
        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }
        XCTAssertTrue(model.activityRunning, "activityRunning should be true")
        model.endActivity()
        XCTAssertEqual(model.activitiesLenght(), 1)
        XCTAssertFalse(model.activityRunning, "activityRunning should be true")
        XCTAssertFalse(model.isCurrentActivityDefined(), "current activity should not be defined")
        XCTAssertTrue(model.valuesRefreshed)
    }

    func testSaveActivities() {
        XCTAssertEqual(model.activitiesLenght(), 0)
        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }
        model.endActivity()
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!))
    }

    func testLoadActivities() {
        XCTAssertEqual(model.activitiesLenght(), 0)
        do{
            try model.startActivity()
        } catch {
            XCTAssertTrue(false, "it should be possible to start activity")
        }
        model.endActivity()
        XCTAssertTrue(model.saveActivities(RTActivitiesModelTest.ArchiveURLTest.path!))
        model.loadActivities(RTActivitiesModelTest.ArchiveURLTest.path!)
        XCTAssertEqual(model.activitiesLenght(), 1)
    }

    func testRefreshValues() {
        XCTAssertFalse(model.currentActivityPaused, "activity should not be paused")
        XCTAssertFalse(model.currentActivityJustResumed, "activity should not be just resumed")
        XCTAssertEqual(model.currentActivityPausedAt, 0)
        XCTAssertEqual(model.currentActivityPausedTime, 0)
    }

}

class RTActivitiesModelFake:RTActivitiesModel{

    var valuesRefreshed:Bool = false
    
    override init() {
        super.init()
    }

    override func refreshValues() {
        valuesRefreshed = true
        super.refreshValues()
    }

}


