//
// Created by MIGUEL MOLDES on 22/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import XCTest
import UIKit

@testable import RunningTracker

class RTInitialViewControllerTest : XCTestCase {

    var vc : RTInitialViewController!
    var navigationController : MockNavigationController!

    override func setUp() {
        super.setUp()

        vc = RTInitialViewController(nibName:"RTInitialView", bundle:nil)
        navigationController = MockNavigationController(rootViewController:vc)
        UIApplication.shared.keyWindow!.rootViewController = navigationController
        XCTAssertNotNil(vc.view)
    }

    override func tearDown() {
        super.tearDown()

    }

    func testInitialSetup() {
        XCTAssertNotNil(vc.initialView.model.model)
        XCTAssertTrue((vc.initialView.model.permissionsDelegate as! RTInitialViewController) == vc)
    }

    func testShouldStartLocationManager() {
        vc.viewDidAppear(false)

        XCTAssertTrue(vc.initialView.model.locationManagerStarted)
        XCTAssertNotNil(vc.initialView.model.locationManager)
    }

    func testShouldStopLocationManager() {
        vc.viewWillDisappear(false)

        XCTAssertFalse(vc.initialView.model.locationManagerStarted)
        XCTAssertNil(vc.initialView.model.locationManager)
    }

    func testActivitiesTouched() {
        vc.initialView.myActivitiesButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(navigationController.lastViewController! is RTActivitiesViewController)
    }

    func testStartActivityTouched() {
        vc.initialView.startButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(navigationController.lastViewController! is RTActiveMapViewController)
    }

    func testShouldShowAlertForPermissions() {
        let navigationExpectation = expectation(description:"alertView set")
        self.navigationController!.asyncExpectation = navigationExpectation

        vc.shouldChangePermissions()

        waitForExpectations(timeout: 1.0){
            error in
            if error != nil {
                XCTFail("shouldChangePermissions was not called")
                return
            }

            XCTAssertTrue(self.navigationController.lastAlertController! is UIAlertController)
        }
    }

}

class MockNavigationController : UINavigationController {

    var lastViewController : UIViewController?
    var lastAlertController : UIViewController?

    var asyncExpectation : XCTestExpectation?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        lastViewController = viewController
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)?) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        self.lastAlertController = viewControllerToPresent

        guard let expectation = asyncExpectation else {
            XCTFail("missing expectation")
            return
        }

        expectation.fulfill()
    }


}
