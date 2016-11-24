//
// Created by MIGUEL MOLDES on 22/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import CoreLocation

@testable import RunningTracker

class RTLocationServiceTest : XCTestCase {

    var service : RTLocationServiceFake!

    override func setUp() {
        super.setUp()
        self.service = RTLocationServiceFake()
    }

    override func tearDown() {
        self.service = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(self.service.locationMgr.delegate)
        XCTAssertEqual(self.service.locationMgr.desiredAccuracy,kCLLocationAccuracyBestForNavigation)
        XCTAssertEqual(self.service.locationMgr.distanceFilter,20.0)
        XCTAssertTrue(self.service.locationMgr.allowsBackgroundLocationUpdates)
        XCTAssertFalse(self.service.locationMgr.pausesLocationUpdatesAutomatically)
    }

    func testShouldChangePermissionsWhenAuthorizedAlways() {
        let delegate = RTTestServiceDelegate()
        self.service.delegate = delegate
        self.service.authorizationStatus = .authorizedAlways

        let delegateExpectation = expectation(description: "delegate called")
        delegate.asyncExpectation = delegateExpectation

        self.service.requestPermissions()

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("error")
                return
            }
            XCTAssertTrue(true)
        }

    }

    func testShouldChangePermissionsWhenRestricted() {
        let delegate = RTTestServiceDelegate()
        self.service.delegate = delegate

        self.service.authorizationStatus = .restricted

        let delegateExpectation = expectation(description: "delegate called")
        delegate.asyncExpectation = delegateExpectation

        self.service.requestPermissions()

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("error")
                return
            }
            XCTAssertTrue(true)
        }

    }

    func testShouldChangePermissionsWhenDenied() {
        let delegate = RTTestServiceDelegate()
        self.service.delegate = delegate
        self.service.authorizationStatus = .denied

        let delegateExpectation = expectation(description: "delegate called")
        delegate.asyncExpectation = delegateExpectation

        self.service.requestPermissions()

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("error")
                return
            }
            XCTAssertTrue(true)
        }

    }

    func testShouldRequestForAuthorization() {
        self.service.authorizationStatus = .notDetermined
        self.service.requestPermissions()
        XCTAssertTrue(self.service.requested)
    }

    func testShouldStartUpdating() {
        self.service.locationManager(self.service.locationMgr, didChangeAuthorization: .denied)
        XCTAssertFalse(self.service.started)

        self.service.locationManager(self.service.locationMgr, didChangeAuthorization: .restricted)
        XCTAssertFalse(self.service.started)

        self.service.locationManager(self.service.locationMgr, didChangeAuthorization: .authorizedAlways)
        XCTAssertFalse(self.service.started)

        self.service.locationManager(self.service.locationMgr, didChangeAuthorization: .authorizedWhenInUse)
        XCTAssertTrue(self.service.started)

        self.service.started = false
        self.service.authorizationStatus = .authorizedWhenInUse
        self.service.locationManager(self.service.locationMgr, didFailWithError: LocationError.denied)
        XCTAssertTrue(self.service.started)
    }

    func testShouldUpdateLocations() {
        let delegate = RTTestServiceDelegate()
        self.service.delegate = delegate

        let delegateExpectation = expectation(description: "delegate called")
        delegate.asyncExpectation = delegateExpectation

        let location1 = CLLocation(latitude: 10.22, longitude: 12.22)
        let location2 = CLLocation(latitude: 11.22, longitude: 12.22)
        let locations = [location1, location2]
        self.service.locationManager(self.service.locationMgr, didUpdateLocations: locations)

        waitForExpectations(timeout: 0.5) {
            error in
            if error != nil {
                XCTFail("didUpdateLocations was not called")
                return
            }

            guard delegate.updatedLocation == location2 else {
                XCTFail("the location updated is wrong")
                return
            }

            XCTAssertTrue(true)
        }

    }

    func testShouldCallDidFail() {
        let delegate = RTTestServiceDelegate()
        self.service.delegate = delegate

        let delegateExpectation = expectation(description:"delegate called")
        delegate.asyncExpectation2 = delegateExpectation

        self.service.locationManager(self.service.locationMgr, didFailWithError: LocationError.denied)

        waitForExpectations(timeout: 0.5) {
            error in
            if error != nil {
                XCTFail("didFail was not called")
                return
            }

            XCTAssertTrue(true)
        }

    }

}

enum LocationError : Error {
    case denied
}

class RTTestServiceDelegate : RTLocationServiceDelegate {

    var asyncExpectation : XCTestExpectation?
    var asyncExpectation2 : XCTestExpectation?
    var updatedLocation : CLLocation!

    func shouldChangePermissions() {
        guard let expectation = asyncExpectation else {
            XCTFail("Missing expectation")
            return
        }

        expectation.fulfill()
    }

    func didUpdateLocation(location:CLLocation) {
        guard let expectation = asyncExpectation else {
            XCTFail("Missing expectation")
            return
        }

        self.updatedLocation = location

        expectation.fulfill()
    }

    func didFail() {
        guard let expectation = asyncExpectation2 else {
            XCTFail("Missing expectation")
            return
        }

        expectation.fulfill()
    }

}
