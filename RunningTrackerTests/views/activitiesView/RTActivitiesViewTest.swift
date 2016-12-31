//
// Created by MIGUEL MOLDES on 31/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import RxCocoa
import RxSwift

@testable import RunningTracker

class RTActivitiesViewTest : XCTestCase {

    var view : RTActivitiesView!
    var viewModel : RTActivitiesViewModelFake!
    var notificationCenter = NotificationCenter.default
    var model : RTActivitiesModelFake = RTActivitiesModelFake()

    override func setUp() {
        super.setUp()
        self.model = RTActivitiesModelFake()
        self.model.mockActivityWithTwoLocations()
        self.model.mockActivityWithTwoLocations()
        self.model.mockActivityWithTwoLocations()
        self.model.mockActivityWithTwoLocations()
        self.viewModel = RTActivitiesViewModelFake(model:self.model, notificationCenter:self.notificationCenter)
        self.view = Bundle.main.loadNibNamed("RTActivitiesView", owner: self)?[0] as! RTActivitiesView
        self.view.viewModel = self.viewModel
    }

    override func tearDown() {
        super.tearDown()
    }

    func testActivitiesLabelHidden() {
        self.model = RTActivitiesModelFake()
        self.viewModel = RTActivitiesViewModelFake(model:self.model, notificationCenter:self.notificationCenter)
        self.view.viewModel = self.viewModel
        self.view.layoutSubviews()
        XCTAssertFalse(self.view.noActivitiesLabel.isHidden)

        self.model = RTActivitiesModelFake()
        self.model.mockActivityWithTwoLocations()
        self.viewModel = RTActivitiesViewModelFake(model:self.model, notificationCenter:self.notificationCenter)
        self.view.viewModel = self.viewModel
        self.view.layoutSubviews()
        XCTAssertTrue(self.view.noActivitiesLabel.isHidden)
    }

    func testTableSetup() {
        let activities = viewModel.activities.count
        if activities > 0 {
            XCTAssertFalse(view.tableView.isHidden)
        } else {
            XCTAssertTrue(view.tableView.isHidden)
        }

        XCTAssertTrue(view.tableView.delegate is RTActivitiesViewModel)
        XCTAssertTrue(view.tableView.dataSource is RTActivitiesViewModel)
    }

    func testDeletingBinding() {

        self.viewModel.activityDeletedExpectation = expectation(description:"activity deleted")

        let index = IndexPath(row: 0, section: 0)
        viewModel.tableView(view.tableView, commit: .delete, forRowAt: index)

        var loadingView = false

        for subView in view.subviews {
            if subView as? RTLoadingView != nil {
                loadingView = true
            }
        }

        XCTAssertTrue(loadingView)

        waitForExpectations(timeout: 3.0){
            error in
            if error != nil {
                print("activity was not deleted")
                return
            }

            for subView in self.view.subviews {
                if subView as? RTLoadingView != nil {
                    XCTFail("shouldn't have a loading view")
                }
            }

        }

    }

    func testRemoveObservers() {
        let center = RTNotificationCenterFake()
        self.viewModel = RTActivitiesViewModelFake(model:self.model, notificationCenter:center)
        self.view.viewModel = self.viewModel
        view.removeFromSuperview()
        XCTAssertTrue(center.removeObserverCalled)
    }
}
