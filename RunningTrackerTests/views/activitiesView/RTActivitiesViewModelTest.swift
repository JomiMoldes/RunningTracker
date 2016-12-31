//
// Created by MIGUEL MOLDES on 28/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@testable import RunningTracker

class RTActivitiesViewModelTest : XCTestCase {

    var viewModel : RTActivitiesViewModelFake!
    var model : RTActivitiesModelFake!
    var view : RTActivitiesView!
    var notificationCenter = RTNotificationCenterFake()

    override func setUp() {
        super.setUp()
        view = Bundle.main.loadNibNamed("RTActivitiesView", owner: self)?[0] as! RTActivitiesView
        view.tableView.register(UINib(nibName:"RTActivityViewCell", bundle:nil), forCellReuseIdentifier: "activityViewCell")
        view.tableView.rowHeight = 44.0
        view.tableView.estimatedRowHeight = 44.0
        model = RTActivitiesModelFake()
        model.mockActivityWithTwoLocations()
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter: notificationCenter)
    }

    override func tearDown() {
        super.tearDown()
        model = nil
        viewModel = nil
    }

    func testInit() {
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        let activitiesAmount = model.activitiesCopy().count
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter:self.notificationCenter)

        XCTAssertEqual(activitiesAmount, viewModel.activities.count)
        let modelLastActivity = model.activitiesCopy()[activitiesAmount - 1]
        let viewModelFirstActivity = viewModel.activities[0]
        XCTAssertEqual(modelLastActivity.startTime, viewModelFirstActivity.startTime)
    }

    func testActivityDeleted() {
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter:self.notificationCenter)
        let activityIndex = 1
        let index = IndexPath(row: activityIndex, section: 0)
        let amount = model.activitiesCopy().count
        let activityToDelete = model.activitiesCopy()[activityIndex]
        let firstActivity = model.activitiesCopy()[0]

        _ = expectation(forNotification: "activityDeleted", object: nil)
        self.viewModel.tableView(self.view.tableView, commit: .delete, forRowAt: index)

        waitForExpectations(timeout: 1.0){
            error in
            if error != nil {
                print("no deleted activity")
                return
            }

            XCTAssertEqual(self.model.activitiesCopy().count, amount - 1)
            NotificationCenter.default.removeObserver(self)
            for activity in self.model.activitiesCopy() {
                XCTAssertNotEqual(activity.startTime, activityToDelete.startTime)
            }
            for localActivity in self.viewModel.activities {
                XCTAssertNotEqual(localActivity.startTime, activityToDelete.startTime)
            }
            let cell = self.viewModel.tableView(self.view.tableView, cellForRowAt: index)
            XCTAssertEqual((cell as! RTActivityViewCell).startTime,firstActivity.startTime)
        }
    }

    func testActivityDeletedBinding() {
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter:self.notificationCenter)

        let activityIndex = 1
        let index = IndexPath(row: activityIndex, section: 0)
        let activityToDelete = model.activitiesCopy()[activityIndex]

        var activityDeleted:RTActivity!
        _ = viewModel.deletingActivity.subscribe(onNext:{
            activity in
            activityDeleted = activity
        })

        _ = expectation(forNotification: "activityDeleted", object: nil)
        self.viewModel.tableView(self.view.tableView, commit: .delete, forRowAt: index)


        waitForExpectations(timeout: 0.1){
            error in
            if error != nil {
                print("activity was not deleted")
                return
            }
            XCTAssertEqual(activityToDelete.startTime, activityDeleted.startTime)
        }
    }

    func testDidSelectRowAt(){
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter:self.notificationCenter)

        let activityIndex = 1
        let index = IndexPath(row: activityIndex, section: 0)
        let activityToSelect = model.activitiesCopy()[activityIndex]

        var activitySelected:RTActivity!
        _ = viewModel.activitySelected.subscribe(onNext:{
            activity in
            activitySelected = activity
        })

        viewModel.selectAsyncExpectation = expectation(forNotification: "activityDeleted", object: nil)
        self.viewModel.tableView(self.view.tableView, didSelectRowAt: index)

        waitForExpectations(timeout: 0.1){
            error in
            if error != nil {
                print("activity was not selected")
                return
            }
            XCTAssertEqual(activityToSelect.startTime, activitySelected.startTime)
        }

    }

    func testRowsInSection() {
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter:self.notificationCenter)

        XCTAssertEqual(viewModel.tableView(self.view.tableView, numberOfRowsInSection: 0), 3)
    }

    func testListenersRemoved() {
        model.mockActivityWithTwoLocations()
        model.mockActivityWithTwoLocations()
        viewModel = RTActivitiesViewModelFake(model:model, notificationCenter:self.notificationCenter)

        let activityIndex = 1
        let index = IndexPath(row: activityIndex, section: 0)

        _ = expectation(forNotification: "activityDeleted", object: nil)

        self.viewModel.tableView(self.view.tableView, commit: .delete, forRowAt: index)

        waitForExpectations(timeout: 0.1){
            error in
            if error != nil {
                print("activity was not deleted")
                return
            }

            XCTAssertFalse(self.notificationCenter.removeObserverCalled)
            self.viewModel.removeObservers()
            XCTAssertTrue(self.notificationCenter.removeObserverCalled)
        }

    }
}
