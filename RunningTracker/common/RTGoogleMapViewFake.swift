//
// Created by MIGUEL MOLDES on 4/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import GoogleMaps

class RTGoogleMapViewFake : GMSMapView {

    var mapCleared : Bool = false

    override func clear() {
        super.clear()
        mapCleared = true
    }


}
