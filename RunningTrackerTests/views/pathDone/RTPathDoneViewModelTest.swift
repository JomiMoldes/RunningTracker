//
// Created by MIGUEL MOLDES on 7/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import XCTest

@testable import RunningTracker

class RTPathDoneViewModelTest : XCTestCase {

    var viewModel: RTPathDoneViewModelFake!
    var model : RTActivitiesModelFake!

    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("AIzaSyBxz-aX7rUCM_YhKVHsAuv-oae6ivkGtmk")
        model = RTActivitiesModelFake()
        viewModel = RTPathDoneViewModelFake(model:model,
                activity: model.fakeActivity())
    }

    override func tearDown() {
        super.tearDown()
        model = nil
        viewModel = nil
    }

    func testInitialSetup() {
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(viewModel.activity)
        let endFlagLocation:CLLocation = self.viewModel.endFlagLocation
        let lastModelLocation = self.viewModel.activity.getActivitiesCopy().last!.location
        XCTAssertEqual(endFlagLocation.distance(from: lastModelLocation!), 0)

        let checkMarks = viewModel.checkMarks
        let activityCheckMarks = viewModel.activity.checkMarks
        XCTAssertTrue(checkMarks!.customCompareLocationsByDistance(dic2: activityCheckMarks))
    }

    func testMapView() {
        let mapView = fakeMapView()

        viewModel.mapExpectation = expectation(description: "map did change")

        viewModel.mapView(mapView, didChange: mapView.camera)

        waitForExpectations(timeout: 1.0){
            error in
            if error != nil {
                XCTFail("map did change was not called")
                return
            }

            XCTAssertTrue(true)
        }
    }

    func fakeMapView() -> RTGMSMapViewFake {
        let activityLocation = model.fakeActivity().getActivitiesCopy()[0]
        let coordinate = activityLocation.location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                longitude: coordinate.longitude, zoom: viewModel.initialZoom)
        let mapFrame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        let mapView = RTGMSMapViewFake.map(withFrame: mapFrame, camera: camera)
        return mapView
    }

    func testMapIsBeingCleared() {
        let mapView = fakeMapView()

        mapView.clearExpectation = expectation(description: "map should be cleared")

        viewModel.lastZoom = 20.0
        viewModel.mapView(mapView, didChange:mapView.camera)

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("map was was not called")
                return
            }

            XCTAssertEqual(self.viewModel.lastZoom, mapView.camera.zoom)
        }

    }


}
