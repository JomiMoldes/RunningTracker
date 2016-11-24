//
// Created by MIGUEL MOLDES on 24/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

protocol RTLocationServiceProtocol {
    weak var delegate : RTLocationServiceDelegate? { get set}
    func requestPermissions()
    func getLocationStatus() -> CLAuthorizationStatus
}
