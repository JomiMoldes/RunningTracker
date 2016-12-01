//
// Created by MIGUEL MOLDES on 23/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import XCTest

@testable import RunningTracker

class RTInitialViewTest : XCTestCase {

    var view : RTInitialView!

    override func setUp() {
        super.setUp()

        view = Bundle.main.loadNibNamed("RTInitialView", owner: self)?[0] as! RTInitialView
        let model = RTActivitiesModelFake()
        let locationService = RTLocationServiceFake()
        view.model = RTInitialViewModel(model:model, locationService:locationService)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSetup(){
        XCTAssertNotNil(view)
        XCTAssertNotNil(view.myActivitiesButton)
        XCTAssertNotNil(view.startButton)
        XCTAssertNotNil(view.bestDistanceView)
        XCTAssertNotNil(view.bestPaceView)
        XCTAssertNotNil(view.distanceLabel)
        XCTAssertNotNil(view.distanceDescLabel)
        XCTAssertNotNil(view.paceLabel)
        XCTAssertNotNil(view.paceDescLabel)
        XCTAssertNotNil(view.turnOnGPSLabel)
        XCTAssertNotNil(view.bestDistanceBGImageView)
        XCTAssertNotNil(view.bestPaceBGImageView)
        XCTAssertNotNil(view.gpsImageView)
        XCTAssertNotNil(view.startViewBGImageView)
    }

    func testBinding(){
        let distanceText = "1200km"
        view.model.distanceVariable.value = distanceText
        XCTAssertEqual(view.distanceLabel.text, distanceText)

        let paceText = "01:00"
        view.model.paceVariable.value = paceText
        XCTAssertEqual(view.paceLabel.text, paceText)

        view.startButton.isEnabled = false
        view.turnOnGPSLabel.isHidden = true
        view.model.gpsRunningVariable.value = true
        XCTAssertTrue(view.startButton.isEnabled)
        XCTAssertTrue(view.turnOnGPSLabel.isHidden)

        let blackImage = UIImage(named:"GPSblack.png")
        let greenImage = UIImage(named:"GPSgreen.png")
        view.model.gpsRunningVariable.value = true

        XCTAssertNotNil(view.gpsImageView.image)

        _ = view.gpsImageView.image?.isEqual(greenImage)
        XCTAssertTrue((view.gpsImageView.image?.isEqual(greenImage))!)

        view.model.gpsRunningVariable.value = false
        XCTAssertTrue((view.gpsImageView.image?.isEqual(blackImage))!)

        self.view.model.gpsRunningVariable.value = false
        self.view.refreshedAfterGPS = false
        self.view.model.gpsRunningVariable.value = true
        XCTAssertTrue(self.view.refreshedAfterGPS)
    }

}
