//
// Created by MIGUEL MOLDES on 17/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTFetchActivitiesOperation {

    var activitiesSavedLocally = [RTActivity]()

    func execute(path:String) -> Promise<([RTActivity],[CKRecord])> {
        return Promise {
            fulfill, reject in

            RTFetchActivitiesLocallyOperation().execute(path).then {
                activities in
                self.activitiesSavedLocally = activities
                return RTFetchActivitiesICloudOperation().execute()
            }.then {
                (records:[CKRecord]) -> Void in
                fulfill((self.activitiesSavedLocally, records))
            }.error(policy: .AllErrors) {
                error in
                switch error {
                default:
                    print(error)
                    break
                }
                reject(error)
            }
        }
    }

}
