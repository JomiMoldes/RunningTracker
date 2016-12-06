//
// Created by MIGUEL MOLDES on 29/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@testable import RunningTracker

class RTActiveMapViewControllerTest : XCTestCase {

    var vc: RTActiveMapViewController!
    var navigationController : RTNavigationControllerMock!
    var fakeModel:RTActivitiesModelFake!
    var fakeViewModel:RTActiveMapViewModelFake!

    override func setUp() {
        super.setUp()
        self.fakeModel = RTActivitiesModelFake()
        vc = RTActiveMapViewController(nibName: "RTActiveMapView", bundle: nil)
        self.fakeViewModel = RTActiveMapViewModelFake(model:self.fakeModel, locationService: RTLocationService())
        vc.viewModel = self.fakeViewModel
        navigationController = RTNavigationControllerMock(rootViewController:vc)
        UIApplication.shared.keyWindow!.rootViewController = navigationController
        XCTAssertNotNil(vc.view)
    }

    override func tearDown() {
        super.tearDown()
        vc = nil
        self.fakeModel = nil
        UIApplication.shared.keyWindow!.rootViewController = nil
        navigationController = nil
    }

    func testViewWillDisappear() {
        vc.viewWillDisappear(false)
        XCTAssertFalse(self.fakeViewModel.locationManagerStarted)
        XCTAssertTrue(self.fakeViewModel.observersRemoved)
    }

    func testViewDidAppear() {
        vc.viewDidAppear(false)
        XCTAssertTrue(vc.activeMapView.model.locationManagerStarted)
        XCTAssertTrue(self.fakeViewModel.timerStarted)
    }

    func testSetup(){
        XCTAssertNotNil(vc.activeMapView.model)
    }

    func testBackButtonWithActivityRunning() {
        self.fakeModel.mockActivityWithTwoLocations(false)

        let asyncExpectation = expectation(description:"show stop options")
        navigationController.asyncExpectation = asyncExpectation

        vc.activeMapView.backButtonView.areaButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 0.2){
            error in
            if error != nil {
                XCTFail("show options was not called")
                return
            }

            XCTAssertTrue(self.navigationController.lastAlertController! is UIAlertController)
        }
    }

    func testBackButtonWithoutActivityRunning() {
        self.fakeModel.mockActivityWithTwoLocations(true)

        let asyncExpectation = expectation(description:"do not show stop options")
        navigationController.asyncExpectation = asyncExpectation

        vc.activeMapView.backButtonView.areaButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 0.5){
            error in
            if error != nil {
                XCTFail("show options was called")
                return
            }

            XCTAssertNil(self.navigationController.lastAlertController)
            XCTAssertNil(self.navigationController.lastViewController)
        }
    }

    func testStopButtonWithActivityRunning() {
        self.fakeModel.mockActivityWithTwoLocations(false)

        let asyncExpectation = expectation(description:"show stop options")
        navigationController.asyncExpectation = asyncExpectation

        vc.activeMapView.backButtonView.areaButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 0.2){
            error in
            if error != nil {
                XCTFail("show options was not called")
                return
            }

            XCTAssertTrue(self.navigationController.lastAlertController! is UIAlertController)
        }
    }

    func testStopButtonWithoutActivityRunning() {
        self.fakeModel.mockActivityWithTwoLocations(true)

        let asyncExpectation = expectation(description:"do not show stop options")
        navigationController.asyncExpectation = asyncExpectation

        vc.activeMapView.backButtonView.areaButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 0.5){
            error in
            if error != nil {
                XCTFail("show options was called")
                return
            }

            XCTAssertNil(self.navigationController.lastAlertController)
        }
    }

    func testPauseButtonWithActivityRunning() {
        self.fakeModel.mockActivityWithTwoLocations(false)
        vc.activeMapView.pauseButton.sendActions(for:.touchUpInside)
        XCTAssertTrue(fakeModel.currentActivityPaused)
    }

    func testPauseButtonWithoutActivityRunning() {
        self.fakeModel.mockActivityWithTwoLocations(true)
        vc.activeMapView.pauseButton.sendActions(for:.touchUpInside)
        XCTAssertFalse(fakeModel.currentActivityPaused)
    }


}