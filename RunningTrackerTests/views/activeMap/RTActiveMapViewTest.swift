//
// Created by MIGUEL MOLDES on 5/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import GoogleMaps
import Foundation
import UIKit
import XCTest
import RxCocoa
import RxSwift
import RxTest
import CoreLocation

@testable import RunningTracker

class RTActiveMapViewTest : XCTestCase {

    var view : RTActiveMapView!
    var viewModel : RTActiveMapViewModelFake!
    var locationService = RTLocationServiceFake()
    var model = RTActivitiesModelFake()

    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("AIzaSyBxz-aX7rUCM_YhKVHsAuv-oae6ivkGtmk")
        view = Bundle.main.loadNibNamed("RTActiveMapView", owner: self)?[0] as! RTActiveMapView
        viewModel = RTActiveMapViewModelFake(model:model, locationService: locationService)
    }

    override func tearDown() {
        super.tearDown()
        view = nil
        viewModel = nil
    }

    func testInit() {
        XCTAssertNotNil(view)
        XCTAssertNotNil(viewModel)
        view.model = viewModel
        XCTAssertNotNil(view.model)
        XCTAssertNotNil(view.mapView)
        XCTAssertNotNil(view.mapMarkersManager)
    }

    func testSetupModel() {
        let mapView = getMapView()
        let mapMarkers = getMapMarkers(mapView:mapView)
        view.mapView = mapView
        view.mapMarkersManager = mapMarkers

        XCTAssertEqual(view.mapContainer.subviews.count, 0)
        view.model = viewModel

        XCTAssertNotNil(view.mapMarkersManager)
        XCTAssertNotNil(view.mapView)
        XCTAssertTrue(view.mapView.delegate is RTActiveMapViewModel)
        XCTAssertEqual(view.mapContainer.subviews.count, 1)
        XCTAssertTrue(view.mapMarkersManager.mapView is RTGMSMapViewFake)
    }

    func testBind() {
        let mapView = getMapView()
        view.mapView = mapView
        XCTAssertFalse((view.mapView as! RTGMSMapViewFake).animated)

        let mapMarkers = getMapMarkers(mapView: mapView)
        view.mapMarkersManager = mapMarkers

        view.model = viewModel

        (view.mapView as! RTGMSMapViewFake).animated = false
        viewModel.locationToAnimateVariable.value = CLLocationCoordinate2D(latitude: 100.0, longitude: 100.0)
        XCTAssertTrue((view.mapView as! RTGMSMapViewFake).animated)

        model.mockActivityWithTwoLocations(false)
        viewModel.didUpdateLocation(location: CLLocation(latitude: 100.2, longitude: 102.1))
        let activity = model.getCurrentActivityCopy()
        XCTAssertEqual((view.mapMarkersManager as! RTMapMarkersManagerFake).activityDrawn?.startTime, activity!.startTime)
        _ = model.endActivity()


        viewModel.chronometerVariable.value = "01:01"
        XCTAssertEqual(view.chronometerLabel.text, "01:01")

        viewModel.distanceVariable.value = "02:01"
        XCTAssertEqual(view.distanceLabel.text, "02:01")

        viewModel.paceVariable.value = "03:01"
        XCTAssertEqual(view.paceLabel.text, "03:01")
    }

    func testPauseButton() {
        model.mockActivityWithTwoLocations(false)
        view.model = viewModel

        let forPause = UIImage(named: "icon_controls_pause.png")
        let forPlay = UIImage(named: "icon_controls_play.png")
        var pauseImage = view.pauseButton.backgroundImage(for: .normal)
        XCTAssertEqual(forPause,pauseImage)
        viewModel.pauseTouched()
        pauseImage = view.pauseButton.backgroundImage(for: .normal)
        XCTAssertEqual(forPlay,pauseImage)

        _ = model.endActivity()
    }

    func testEndFlag() {
        model.mockActivityWithTwoLocations(false)
        let mapView = getMapView()
        let mapMarkers = getMapMarkers(mapView: mapView)
        view.mapView = mapView
        view.mapMarkersManager = mapMarkers
        view.model = viewModel

        let asyncExpectation = expectation(description: "endFlag")
        mapMarkers.endFlagExpectation = asyncExpectation

        viewModel.endActivity()

        waitForExpectations(timeout: 3.0) {
            error in
            if error != nil {
                XCTFail("end flag was not called")
                return
            }

            XCTAssertTrue(true)
        }
    }

    func testZoomReaction() {
        let mapView = getMapView()
        view.mapView = mapView
        let mapMarkers = getMapMarkers(mapView: mapView)
        view.mapMarkersManager = mapMarkers
        view.model = viewModel

        model.mockActivityWithTwoLocations(false)

        let asyncExpectation = expectation(description: "zoom")
        viewModel.mapViewAsyncExpectation = asyncExpectation

        let camera = GMSCameraPosition.camera(withLatitude: 56.52356, longitude: 13.45097995, zoom: 11.0)
        viewModel.mapView(mapView, didChange: camera)

        waitForExpectations(timeout: 1.0) {
            error in
            if error != nil {
                XCTFail("no zoom was called")
                return
            }
            let activity = self.model.getCurrentActivityCopy()
            XCTAssertEqual((self.view.mapMarkersManager as! RTMapMarkersManagerFake).activityDrawn?.startTime, activity!.startTime)

            let checkMarks = self.viewModel.checkMarksVariable.value[0]
            let activityCheckMarks = mapMarkers.checkMarksToDraw!

            for (key, value) in checkMarks {
                let location1 = value
                let location2:CLLocation = activityCheckMarks[key]!
                XCTAssertNotNil(location2)
                XCTAssertTrue(location2.distance(from: location1).isZero)
            }

            _ = self.model.endActivity()

        }
    }

    private func getMapView() -> RTGMSMapViewFake {
        let camera = GMSCameraPosition.camera(withLatitude: 52.52356, longitude: 13.45097995, zoom: 15)
        let mapView = RTGMSMapViewFake.map(withFrame: CGRect(x: 0,y: 0,width: 200, height: 200), camera: camera)
        return mapView
    }

    private func getMapMarkers(mapView:RTGMSMapViewFake) -> RTMapMarkersManagerFake {
        return RTMapMarkersManagerFake(mapView:mapView)!
    }



}
