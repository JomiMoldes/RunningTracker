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

    func saveActivities(activities:[RTActivity], path:String) -> Promise<[RTActivity]> {
        self.activitiesSavedLocally = activities

        return Promise {
            fulfill, reject in

            let recordsHelper = RTGlobalModels.sharedInstance.activitiesAndRecordsHelper
            RTSaveLocallyOperation().execute(activities, path:path)
            RTSaveICloudOperation().execute(recordsHelper.createRecordsForActivity(activities[activities.count - 1])).then {
                success in
                fulfill(self.activitiesSavedLocally!)
            }.error(policy:.AllErrors){
                error in
                fulfill(self.activitiesSavedLocally!)
            }
        }
    }


}
