//
// Created by MIGUEL MOLDES on 6/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import GoogleMaps

class RTGMSMapViewFake : GMSMapView {

    var animated : Bool = false

    override open func animate(toLocation location: CLLocationCoordinate2D) {
        animated = true
        super.animate(toLocation:location)
    }





}
