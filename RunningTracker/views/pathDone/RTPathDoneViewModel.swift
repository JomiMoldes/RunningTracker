//
// Created by MIGUEL MOLDES on 7/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import GoogleMaps

class RTPathDoneViewModel : NSObject, GMSMapViewDelegate {

    let initialZoom : Float = 15.0
    var lastZoom : Float = 15.0
    var zoomChanged  = PublishSubject<Float>()

    var distance:String {
        get {
            return String(format:"%.2f", activity.distance / 1000)
        }
    }

    var pace:String {
        get {
            let pace = activity.getPace()
            return pace.getMinutes() + ":" + pace.getSeconds()
        }
    }

    var chronometer:String {
        get {
            let duration = activity.getDuration()
            return duration.getHours() + ":" + duration.getMinutes() + ":" + duration.getSeconds()
        }
    }

    var endFlagLocation : CLLocation!
    var checkMarks : [Int:CLLocation]!

    let model : RTActivitiesModel!
    let activity : RTActivity!

    init?(model:RTActivitiesModel, activity: RTActivity){
        self.model = model
        self.activity = activity
        super.init()
        self.setupFlags()
    }

    func setupFlags() {
        endFlagLocation = self.activity.getActivitiesCopy().last!.location
        checkMarks = self.activity.checkMarks
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoom = mapView.camera.zoom
        if zoom != lastZoom {
            DispatchQueue.main.async {
                mapView.clear()
                self.lastZoom = zoom
                self.zoomChanged.onNext(self.lastZoom)
            }

        }
    }

}
