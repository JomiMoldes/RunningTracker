//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

enum RTStoreError:ErrorType {
    case RTICloudNotAvailable
    case RTUserDefaultsNotAvailable

}

class RTStoreActivitiesManager2 {

    var activitiesSavedLocally : [RTActivity]?
    var allActivitiesRecords = [CKRecord]()
    var allLocationsRecords = [CKRecord]()


    func start(path:String) -> Promise<[RTActivity]> {
        return Promise {
            fulfill, reject in

            RTFetchActivitiesOperation().execute(path).then {
                (activities,records) in
                return RTSyncOperation().execute(activities, iCloudActivities: records, path: path)
            }.then {
                activities -> Void in
                self.activitiesSavedLocally = activities
                fulfill(self.activitiesSavedLocally!)
            }.error(policy:.AllErrors) {
                error in
                reject(error)
            }
        }
    }


}
