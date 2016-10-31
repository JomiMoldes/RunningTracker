//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

enum RTStoreError:Error {
    case rtiCloudNotAvailable
    case rtUserDefaultsNotAvailable

}

class RTStoreActivitiesManager {

    var activitiesSavedLocally : [RTActivity]?
    var allActivitiesRecords = [CKRecord]()
    var allLocationsRecords = [CKRecord]()


    func loadActivities(_ path:String) -> Promise<[RTActivity]> {
        return Promise {
            fulfill, reject in

            RTFetchActivitiesOperation().execute(path).then {
                (activities,records) -> Promise<[RTActivity]> in
                self.allActivitiesRecords = records
                return RTSyncOperation().execute(activities, iCloudActivities: records, path: path)
            }.then {
                activities -> Void in
                self.activitiesSavedLocally = activities
                fulfill(self.activitiesSavedLocally!)
            }.catch(policy:.allErrors) {
                error in
                reject(error)
            }
        }
    }

    func saveActivities(_ activities:[RTActivity], path:String) -> Promise<[RTActivity]> {
        self.activitiesSavedLocally = activities

        return Promise {
            fulfill, reject in

            let recordsHelper = RTGlobalModels.sharedInstance.activitiesAndRecordsHelper
            RTSaveLocallyOperation().execute(activities, path:path)
            RTSaveICloudOperation().execute(recordsHelper.createRecordsForActivity(activities[activities.count - 1])).then {
                success in
                fulfill(self.activitiesSavedLocally!)
            }.catch(policy:.allErrors){
                error in
                fulfill(self.activitiesSavedLocally!)
            }
        }
    }

    func deleteActivity(_ activity:RTActivity, path:String) -> Promise<Bool>{
        return Promise {
            fulfill, reject in

            var recordsToDelete : [CKRecord] = [CKRecord]()
            let activityId = Int(activity.startTime)

            self.loadActivities(path).then {
                activities -> Promise<[CKRecord]> in
                self.activitiesSavedLocally = activities
                self.activitiesSavedLocally = RTDeleteActivityLocallyOperation().execute(self.activitiesSavedLocally!, activity: activity, path: path)
                return RTFetchLocationsICloudOperation().execute([activityId])
            }.then {
                locationRecords -> Promise<Bool> in
                let activityRecord = RTGlobalModels.sharedInstance.activitiesAndRecordsHelper.getRecordFromRecordsListByActivityId(activityId, records: self.allActivitiesRecords)
                recordsToDelete.append(activityRecord)
                recordsToDelete += locationRecords
                return RTDeleteActivityICloudOperation().execute(recordsToDelete)
            }.then {
                success in
                fulfill(success)
            }.catch(policy:.allErrors) {
                error in
                reject(error)
            }

        }


    }


}
