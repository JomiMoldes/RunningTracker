//
// Created by MIGUEL MOLDES on 24/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

@testable import RunningTracker

class RTLocationServiceFake: RTLocationService {

    var authorizationStatus : CLAuthorizationStatus = .denied

    override func getLocationStatus() -> CLAuthorizationStatus {
        return authorizationStatus
    }

}
