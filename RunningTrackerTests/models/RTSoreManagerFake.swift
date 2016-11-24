//
// Created by MIGUEL MOLDES on 23/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import PromiseKit

@testable import RunningTracker

class RTSoreManagerFake: RTStoreActivitiesManager {

    override func loadActivities(_ path:String) -> Promise<[RTActivity]> {
        return Promise {
            fulfill, reject in
            fulfill([RTActivity]())
        }

    }

    override func saveActivities(_ activities:[RTActivity], path:String) -> Promise<[RTActivity]> {
        return Promise {
            fulfill, reject in
            fulfill(activities)
        }
    }
}
