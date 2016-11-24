//
// Created by MIGUEL MOLDES on 24/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

@testable import RunningTracker

class RTLocationManagerFake: RTLocationServiceProtocol {

    var requestedPermissions = false

    weak var delegate : RTLocationServiceDelegate?

    func requestPermissions() {
        requestedPermissions = true
    }

    func getLocationStatus() -> CLAuthorizationStatus {
        return .notDetermined
    }


}
