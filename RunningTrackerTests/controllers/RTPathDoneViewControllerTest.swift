//
// Created by MIGUEL MOLDES on 7/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@testable import RunningTracker

class RTPathDoneViewControllerTest : XCTestCase {

    var vc : RTPathDoneViewController!
    var navigationController : RTNavigationControllerMock!
    var model : RTActivitiesModelFake!

    override func setUp() {
        super.setUp()
        vc = RTPathDoneViewController(nibName: "RTPathDoneView", bundle: nil)
        navigationController = RTNavigationControllerMock(rootViewController: vc)
        UIApplication.shared.keyWindow!.rootViewController = navigationController
        model = RTActivitiesModelFake()
        vc.pathDoneViewModel = RTPathDoneViewModelFake(model:model, activity: model.fakeActivity())
        XCTAssertNotNil(vc.view)
    }

    override func tearDown() {
        super.tearDown()
        vc = nil
    }

    func testInitialSetup() {
        XCTAssertNotNil(vc.pathDoneView)
        setupViewModel()
        XCTAssertNotNil(vc.pathDoneView.model)
    }

    func setupViewModel() {
        vc.pathDoneView.model = RTPathDoneViewModel(model:model, activity:model.fakeActivity())
    }

    func testBackButton() {
        let asyncExpectaction = expectation(description: "backButton")
        navigationController.asyncExpectation = asyncExpectaction

        vc.pathDoneView.backButtonView.areaButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 0.5) {
            error in
            if error != nil {
                XCTFail("backButton was not called")
                return
            }

            XCTAssertNil(self.navigationController.lastViewController)
        }
    }




}
