//
// Created by MIGUEL MOLDES on 9/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import GoogleMaps
import XCTest

@testable import RunningTracker

class RTPathDoneViewModelFake : RTPathDoneViewModel {

    var fakeModel:RTActivitiesModelFake {
        get {
            return model as! RTActivitiesModelFake
        }
    }

    var mapExpectation : XCTestExpectation?
    var endFlagExpectation : XCTestExpectation?

    override func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        super.mapView(mapView, didChange: position)
        mapExpectation?.fulfill()
    }

    func simulateMapChange() {
        let mapView = fakeMapView()
        self.lastZoom = self.initialZoom - 5
        self.mapView(mapView, didChange: mapView.camera)
    }

    func fakeMapView() -> RTGMSMapViewFake {
        let activityLocation = fakeModel.fakeActivity().getActivitiesCopy()[0]
        let coordinate = activityLocation.location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                longitude: coordinate.longitude, zoom: initialZoom)
        let mapFrame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        let mapView = RTGMSMapViewFake.map(withFrame: mapFrame, camera: camera)
        return mapView
    }


}
