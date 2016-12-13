//
// Created by MIGUEL MOLDES on 7/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import GoogleMaps

@testable import RunningTracker

class RTPathDoneViewTest : XCTestCase {

    var view:RTPathDoneView!
    var viewModel:RTPathDoneViewModelFake {
        get {
            return view.model as! RTPathDoneViewModelFake
        }
    }

    var markersManager : RTMapMarkersManagerFake {
        get {
            return view.markersManager as! RTMapMarkersManagerFake
        }
    }

    let activitiesModel = RTActivitiesModelFake()

    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("AIzaSyBxz-aX7rUCM_YhKVHsAuv-oae6ivkGtmk")
        view = Bundle.main.loadNibNamed("RTPathDoneView", owner: self)?[0] as! RTPathDoneView
        view.model = RTPathDoneViewModelFake(model:activitiesModel, activity: activitiesModel.fakeActivity())
        view.markersManager = RTMapMarkersManagerFake(mapView: view.mapView)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitialSetup() {
        XCTAssertNotNil(view)
        XCTAssertNotNil(view.markersManager)

        XCTAssertNotNil(view.backButtonView)
        XCTAssertNotNil(view.topBarView)
        XCTAssertNotNil(view.bottomBarView)
        XCTAssertNotNil(view.chronometerLabel)
        XCTAssertNotNil(view.distanceLabel)
        XCTAssertNotNil(view.paceLabel)
        XCTAssertNotNil(view.distDescLabel)
        XCTAssertNotNil(view.paceDescLabel)
        XCTAssertNotNil(view.mapContainer)
    }

    func testModelSetup(){
        XCTAssertNotNil(view.model)
    }

    func testZoomBinding() {
        markersManager.redrawMarkersExpectation = expectation(description: "redraw Markers")
        viewModel.simulateMapChange()
        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("redraw markers was not called")
                return
            }

            XCTAssertTrue(self.markersManager.checkMarksToDraw!.customCompareLocationsByDistance(dic2: self.viewModel.checkMarks))
        }

    }

    func testMap() {
        XCTAssertNotNil(view.mapView)
        XCTAssertFalse(view.mapView.isMyLocationEnabled)
        XCTAssertTrue(view.mapView.delegate is RTPathDoneViewModel)
    }

    func testLabels() {
        let activity:RTActivity! = viewModel.model.getCurrentActivityCopy()

        let duration = activity.getDuration()
        let durationString = duration.getHours() + ":" + duration.getMinutes() + ":" + duration.getSeconds()
        XCTAssertEqual(view.chronometerLabel.text, durationString)

        let pace = activity.getPace()
        let paceString = pace.getMinutes() + ":" + pace.getSeconds()
        XCTAssertEqual(view.paceLabel.text, paceString)

        let distanceString = String(format:"%.2f", activity.distance / 1000)
        XCTAssertEqual(view.distanceLabel.text, distanceString)
    }

    func testRedrawMarkersAfterSettingViewModel() {
        view.markersManager = RTMapMarkersManagerFake(mapView: view.mapView)
        markersManager.redrawMarkersExpectation = expectation(description: "redraw Markers")

        view.model = RTPathDoneViewModelFake(model:activitiesModel, activity: activitiesModel.fakeActivity())

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("redraw markers was not called after setting the view model")
                return
            }

            XCTAssertTrue(true)
        }
    }

    func testDrawPathAfterSettingViewModel() {
        view.markersManager = RTMapMarkersManagerFake(mapView: view.mapView)
        markersManager.drawPathExpectation = expectation(description: "draw Path")

        view.model = RTPathDoneViewModelFake(model:activitiesModel, activity: activitiesModel.fakeActivity())

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("drawPath was not called after setting the view model")
                return
            }

            XCTAssertTrue(true)
        }
    }

    func testDrawEndFlagAfterSettingViewModel() {
        view.markersManager = RTMapMarkersManagerFake(mapView: view.mapView)
        markersManager.endFlagExpectation = expectation(description: "endFlag")

        view.model = RTPathDoneViewModelFake(model:activitiesModel, activity: activitiesModel.fakeActivity())

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("addMarkerWithLocation was not called after setting the view model")
                return
            }

            XCTAssertTrue(true)
        }
    }


}
