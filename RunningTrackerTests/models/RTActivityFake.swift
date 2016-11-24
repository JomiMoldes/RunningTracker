//
// Created by MIGUEL MOLDES on 23/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation
import PromiseKit

@testable import RunningTracker

class RTActivityFake:RTActivity {

    var fakePace = 0.0

    override func getPace() -> Double {
        return fakePace
    }

}
