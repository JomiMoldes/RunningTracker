//
// Created by MIGUEL MOLDES on 5/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import RxCocoa
import RxSwift
import RxTest
import GoogleMaps
import CoreLocation

@testable import RunningTracker

class RTActiveMapViewTest : XCTestCase {

    var view : RTActiveMapView!

    override func setUp() {
        super.setUp()
//        UIStoryboard(name: "main", bundle: "activeMapView").
//        let algo = Bundle.main.loadNibNamed("activeMapView", owner: self)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        XCTAssertNotNil(view)
    }



}
