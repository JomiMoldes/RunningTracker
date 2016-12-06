//
// Created by MIGUEL MOLDES on 4/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxTest
import XCTest
import CoreLocation
import GoogleMaps

@testable import RunningTracker

class RTActiveMapViewModelTest : XCTestCase {

    var viewModel : RTActiveMapViewModelFake!
    var locationService = RTLocationManagerFake()
    var model = RTActivitiesModelFake()

    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("AIzaSyBxz-aX7rUCM_YhKVHsAuv-oae6ivkGtmk")
        self.viewModel = RTActiveMapViewModelFake(model:model, locationService:self.locationService)
    }

    override func tearDown() {
        super.tearDown()
        _ = self.model.endActivity()
        self.viewModel.endActivity()
        self.viewModel.removeObservers()
        self.viewModel = nil
    }

    func testSetup() {
        XCTAssertNotNil(self.viewModel)
        XCTAssertNotNil(self.viewModel.model)
        XCTAssertNotNil(self.viewModel.locationManager)
    }

    func testLocationService() {
        self.viewModel.startLocation()
        XCTAssertEqual(locationService.delegate! as! RTActiveMapViewModel, viewModel)
        XCTAssertTrue(locationService.requestedPermissions)
        XCTAssertTrue(viewModel.locationManagerStarted)
    }

    func testKillLocationService() {
        self.viewModel.killLocation()
        XCTAssertFalse(viewModel.locationManagerStarted)
        XCTAssertNil(viewModel.locationManager)
    }

    func testEndActivity() {
        self.model.mockActivityWithTwoLocations(false)
        let lastActivity = self.model.addLocationToCurrentActivity()
        self.viewModel.endActivity()
        XCTAssertTrue(viewModel.showActivityIndicatorVariable.value)

        let asyncExpectation = expectation(forNotification: "activitiesSaved", object: nil, handler: nil)
        waitForExpectations(timeout: 3.0) {
            error in

            if error != nil {
                print("no activities saved")
                return
            }

            XCTAssertTrue(true)
        }

        let locations:[CLLocation] = self.viewModel.endFlagLocationVariable.value
        let flagLocation: CLLocation = locations[locations.count - 1]
        let lastLocation: CLLocation = lastActivity!.location
        XCTAssertTrue(lastLocation.distance(from: flagLocation).isZero)

        XCTAssertEqual(self.viewModel.paceVariable.value, "08:57")

        XCTAssertNil(self.viewModel.timer)
    }

    func testTimer() {
        self.model.mockActivityWithTwoLocations(false)
        self.viewModel.setupTimer()
        XCTAssertTrue(self.viewModel.timerStarted)
        self.viewModel.tickTimer()
        XCTAssertEqual(self.viewModel.chronometerVariable.value, "00:00:30")
        XCTAssertEqual(self.viewModel.distanceVariable.value, "0.06")
        XCTAssertEqual(self.viewModel.paceVariable.value, "02:59")
    }

    func testPauseTouched() {
        self.model.mockActivityWithTwoLocations(false)
        viewModel.pauseTouched()
        XCTAssertNil(viewModel.timer)
        XCTAssertTrue(model.currentActivityPaused)
        XCTAssertEqual(model.currentActivityPausedAt, model.getNow())
        let image = viewModel.pauseButtonImageVariable.value
        XCTAssertEqual(image, UIImage(named: "icon_controls_play.png"))


        viewModel.pauseTouched()
        XCTAssertTrue(self.viewModel.timerStarted)
        XCTAssertFalse(model.currentActivityPaused)
        let pauseImage = viewModel.pauseButtonImageVariable.value
        XCTAssertEqual(pauseImage, UIImage(named: "icon_controls_pause.png"))
    }

    func testDidUpdateLocation() {
        self.model.mockActivityWithTwoLocations(false)
        let location = CLLocation(latitude:110.2, longitude:100.2)
        XCTAssertEqual((viewModel.activityToDrawVariable.value as! [RTActivity]).count, 0)
        viewModel.didUpdateLocation(location: location)
        XCTAssertEqual((viewModel.activityToDrawVariable.value as! [RTActivity]).count, 1)
        XCTAssertEqual(self.model.getCurrentActivityCopy()!.getActivitiesCopy().count,3)
    }

    func testMapView() {
        self.model.mockActivityWithTwoLocations(false)
        let activity:RTActivity! = self.model.getCurrentActivityCopy()
        let location = CLLocation(latitude:110.2, longitude:100.2)
        let camera = GMSCameraPosition.camera(withLatitude: 52.52356, longitude: 13.45097995, zoom: 10)
        let mapView = RTGoogleMapViewFake.map(withFrame: CGRect(x: 0,y: 0,width: 400, height: 400), camera: camera)

        XCTAssertEqual(viewModel.lastZoomVariable.value, 18.0)
        XCTAssertFalse(mapView.mapCleared)
        viewModel.mapView(mapView, didChange: camera)

        XCTAssertEqual(viewModel.lastZoomVariable.value, 10.0)

        let asyncExpectation = expectation(description:"map should be cleared")
        viewModel.mapViewAsyncExpectation = asyncExpectation

        waitForExpectations(timeout: 1.0){
            error in
            if error != nil {
                XCTFail("map clear was not called")
                return
            }

            XCTAssertTrue(mapView.mapCleared)
            XCTAssertEqual((self.viewModel.activityToDrawVariable.value[0] as! RTActivity).startTime, activity.startTime)

            let checkMarks = self.viewModel.checkMarksVariable.value[0]
            let activityCheckMarks = activity.checkMarks

            for (key, value) in checkMarks {
                let location1 = value
                let location2:CLLocation = activity.checkMarks[key]!
                XCTAssertNotNil(location2)
                XCTAssertTrue(location2.distance(from: location1).isZero)
            }


        }


    }




}
