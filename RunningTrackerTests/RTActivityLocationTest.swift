//
// Created by MIGUEL MOLDES on 29/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import XCTest
import CoreLocation
@testable import RunningTracker

class RTActivityLocationTest : XCTestCase {

    var activityLocation : RTActivityLocation!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        activityLocation = nil
        super.tearDown()
    }

    func testInit() {
        let location = CLLocation(latitude:10.00, longitude: 11.00)
        let now = NSDate().timeIntervalSince1970
        self.activityLocation = RTActivityLocation(location:location, timestamp: now + 10)
        XCTAssertEqual(self.activityLocation.timestamp, now + 10)
        XCTAssertEqual(self.activityLocation.location, location)
        XCTAssertFalse(self.activityLocation.firstAfterResumed)
    }

    func testInit2() {
        let location = CLLocation(latitude:10.00, longitude: 11.00)
        let now = NSDate().timeIntervalSince1970
        let firstAfterResumed = true
        self.activityLocation = RTActivityLocation(location:location, timestamp: now, firstAfterResumed: firstAfterResumed)
        XCTAssertEqual(self.activityLocation.timestamp, now)
        XCTAssertEqual(self.activityLocation.location, location)
        XCTAssertTrue(self.activityLocation.firstAfterResumed)
    }

    func testInitWithCoder() {
        let location = CLLocation(latitude:10.00, longitude: 11.00)
        let now = NSDate().timeIntervalSince1970
        let firstAfterResumed = true
        self.activityLocation = RTActivityLocation(location:location, timestamp: now, firstAfterResumed: firstAfterResumed)

        let data = NSKeyedArchiver.archivedDataWithRootObject(self.activityLocation)
        
        let copyLocation : RTActivityLocation = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! RTActivityLocation

        XCTAssertEqual(copyLocation.timestamp, now)
        XCTAssertEqual(copyLocation.location.coordinate.latitude, location.coordinate.latitude)
        XCTAssertTrue(copyLocation.firstAfterResumed)
    }


}
