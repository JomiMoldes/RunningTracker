//
// Created by MIGUEL MOLDES on 23/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import XCTest
import RxTest
import CoreLocation

@testable import RunningTracker

class RTInitialViewModelTest : XCTestCase {

    var viewModel : RTInitialViewModelFake!
    var model : RTActivitiesModelFake!
    var locationService = RTLocationManagerFake()
    var delegate = RTTestServiceDelegate()

    override func setUp() {
        super.setUp()
        model = RTActivitiesModelFake()
        model.mockActivityWithTwoLocations()
        viewModel = RTInitialViewModelFake(model:model!, locationService: locationService)
        viewModel.permissionsDelegate = delegate
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitial() {
        XCTAssertNotNil(viewModel.model)
        XCTAssertEqual(viewModel.distanceVariable.value, "111.66 km")
        XCTAssertEqual(viewModel.paceVariable.value, "02:59")

        let blackImage = UIImage(named:"GPSblack.png")
        XCTAssertTrue(viewModel.gpsImageVariable.value.isEqual(blackImage))
    }

    func testShouldChangeGPSImage() {
        let blackImage = UIImage(named:"GPSblack.png")
        let greenImage = UIImage(named:"GPSgreen.png")
        viewModel.gpsRunningVariable.value = true
        XCTAssertTrue(viewModel.gpsImageVariable.value.isEqual(greenImage))

        viewModel.gpsRunningVariable.value = false
        XCTAssertTrue(viewModel.gpsImageVariable.value.isEqual(blackImage))
    }

    func testLocationStarted() {
        XCTAssertFalse(viewModel.locationManagerStarted)
        XCTAssertFalse(locationService.requestedPermissions)
        viewModel.startLocation()
        XCTAssertTrue(viewModel.locationManagerStarted)
        XCTAssertNotNil(viewModel.locationManager?.delegate)
        XCTAssertTrue(locationService.requestedPermissions)
    }

    func testKillLocations() {
        viewModel.startLocation()
        XCTAssertNotNil(viewModel.locationManager?.delegate)
        viewModel.killLocation()
        XCTAssertFalse(viewModel.locationManagerStarted)
        XCTAssertNil(viewModel.locationManager)
    }

    func testLocationServiceDelegate () {
        let myProtocol = viewModel as! RTLocationServiceDelegate
        XCTAssertNotNil(myProtocol)

        viewModel.gpsRunningVariable.value = false
        myProtocol.didUpdateLocation?(location: CLLocation(latitude:100.22, longitude: 100.2))
        XCTAssertTrue(viewModel.gpsRunningVariable.value)

        myProtocol.didFail?()
        XCTAssertFalse(viewModel.gpsRunningVariable.value)
    }

    func testShouldChangePermissions() {
        let delegateExpectation = expectation(description: "delegate called")
        delegate.asyncExpectation = delegateExpectation

        delegate.shouldChangePermissions()

        waitForExpectations(timeout: 0.5) {
            error in
            if error != nil {
                XCTFail("error")
                return
            }
            XCTAssertTrue(true)
        }
    }


}


