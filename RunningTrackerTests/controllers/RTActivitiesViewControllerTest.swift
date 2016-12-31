//
// Created by MIGUEL MOLDES on 28/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@testable import RunningTracker

class RTActivitiesViewControllerTest : XCTestCase {

    var viewController : RTActivitiesViewController!
    var viewModel : RTActivitiesViewModelFake!
    var model : RTActivitiesModelFake!
    var navigationFake : RTNavigationControllerMock!

    override func setUp() {
        super.setUp()
        viewController = RTActivitiesViewController(nibName: "RTActivitiesView", bundle: nil)
        navigationFake = RTNavigationControllerMock(rootViewController: viewController)
        model = RTActivitiesModelFake()
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        viewController.activitiesViewModel = RTActivitiesViewModelFake(model:model, notificationCenter: NotificationCenter.default)
    }

    override func tearDown() {
        super.tearDown()
        model = nil
        viewController = nil
    }

    func testView() {
        XCTAssertNotNil(viewController.view)
        XCTAssertNotNil(viewController.activitiesViewModel)
    }

    func testBackButton() {
        let asyncExpectation = expectation(description: "back buitton")
        navigationFake.asyncExpectation = asyncExpectation

        viewController.activitiesView.backButtonView.areaButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 1.0){
            error in
            if error != nil {
                print("no back button")
                return
            }
            XCTAssertNil(self.navigationFake.lastViewController)
        }
    }

    func testBind() {
        navigationFake.pushExpectation = expectation(description: "activity selected")

        let index = IndexPath(row: 0, section: 0)
        viewController.activitiesViewModel.tableView(viewController.activitiesView.tableView, didSelectRowAt: index)

        waitForExpectations(timeout: 1.0){
            error in
            if error != nil {
                print("no activity selected")
                return
            }

            XCTAssertTrue(self.navigationFake.lastViewController is RTPathDoneViewController)
            let pathDoneViewModel = (self.navigationFake.lastViewController as! RTPathDoneViewController).pathDoneViewModel!
            let activitySelected = pathDoneViewModel.activity!
            XCTAssertEqual(activitySelected.startTime, self.model.activitiesCopy()[1].startTime)
        }

    }


}
