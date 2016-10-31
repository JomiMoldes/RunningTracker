//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTSyncOperation {

    var localActivitiesDic: Dictionary = [Int: RTActivity]()
    var iCloudActivitiesDic: Dictionary = [Int: CKRecord]()
    var iCloudLocationsDic: Dictionary = [Int: CKRecord]()
    var savedLocalActivities: [RTActivity]!

    var path: String!

    func execute(_ localActivities: [RTActivity], iCloudActivities: [CKRecord], path: String) -> Promise<[RTActivity]> {
        savedLocalActivities = localActivities
        prepareLocalActivitiesDic(localActivities)
        prepareICloudActivitiesDic(iCloudActivities)
        self.path = path

        return Promise {
            fulfill, reject in

            let recordsMissingLocally = self.getRecordsMissingLocally(iCloudActivities)
            var recordsToAddOnICloud = [CKRecord]()

            RTFetchLocationsICloudOperation().execute(recordsMissingLocally).then {
                records -> Promise<Bool> in
                if records.count > 0 {
                    self.prepareICloudLocationsDic(records)
                }
                self.saveDifferencesLocally(recordsMissingLocally)
                recordsToAddOnICloud = self.getRecordsMissingOnICloud(self.savedLocalActivities, iCloudActivities: iCloudActivities)
                return RTSaveICloudOperation().execute(recordsToAddOnICloud)
            }.then {
                success in

                fulfill(self.savedLocalActivities)
            }.catch(policy: .allErrors) {
                error in

                print(error)
                fulfill(self.savedLocalActivities)
            }
        }
    }

    fileprivate func saveDifferencesLocally(_ activitiesRecordsIds: [Int]) -> Bool {
        for activityRecordId in activitiesRecordsIds {
            let activityRecord = iCloudActivitiesDic[activityRecordId]!
            let locations = self.getLocationsLists(activityRecordId)
            let activityLocations = locations.activities
            let afterResumedLocations = locations.afterLocations

            let activity = RTActivity(activities: activityLocations,
                    startTime: activityRecord["starttime"] as! Double,
                    finishTime: activityRecord["endtime"] as! Double,
                    pausedTime2: activityRecord["pausedtime"] as! Double,
                    distance: activityRecord["distance"] as! Double,
                    locationsAfterResumed: afterResumedLocations)
            self.savedLocalActivities.append(activity!)
        }

        return RTSaveLocallyOperation().execute(self.savedLocalActivities, path:self.path)
    }

    fileprivate func getRecordsMissingOnICloud(_ localActivities: [RTActivity], iCloudActivities: [CKRecord]) -> [CKRecord] {
        var recordsToAdd = [CKRecord]()
        let recordsHelper = RTGlobalModels.sharedInstance.activitiesAndRecordsHelper
        for activity: RTActivity in localActivities {
            let activityId = Int(activity.startTime)
            if iCloudActivitiesDic[activityId] == nil {
                let newRecord = recordsHelper.createRecordByActivity(activity)
                recordsToAdd.append(newRecord)
                recordsToAdd += recordsHelper.createLocationRecords(activity)
            }
        }
        return recordsToAdd
    }

    fileprivate func getRecordsMissingLocally(_ iCloudActivities: [CKRecord]) -> [Int] {
        var recordsIds = [Int]()

        for activityRecord in iCloudActivities {
            let recordId = activityRecord.value(forKey: "starttime") as! Int
            if localActivitiesDic[recordId] == nil {
                recordsIds.append(recordId)
            }
        }

        return recordsIds
    }

    fileprivate func getLocationsLists(_ activityId: Int) -> (activities:[RTActivityLocation], afterLocations:[CLLocation]) {
        var locations = [RTActivityLocation]()
        let locationRecord = iCloudLocationsDic[activityId]!

        let locationsList = locationRecord["locationslist"] as! [CLLocation]
        let afterResumedList = locationRecord["locationsafterresumed"] as! [CLLocation]

        for location: CLLocation in locationsList {
            let firstAfterResumed: Bool = afterResumedList.contains(location)
            let locationActivity = RTActivityLocation(location: location, timestamp: location.timestamp.timeIntervalSince1970, firstAfterResumed: firstAfterResumed)
            locations.append(locationActivity!)
        }
        return (locations, afterResumedList)
    }

    fileprivate func prepareLocalActivitiesDic(_ localActivities: [RTActivity]) {
        for activity: RTActivity in localActivities {
            let activityId = Int(activity.startTime)
            localActivitiesDic[activityId] = activity
        }
    }

    fileprivate func prepareICloudActivitiesDic(_ activities: [CKRecord]) {
        for record in activities {
            let recordId = record["starttime"] as! Int
            iCloudActivitiesDic[recordId] = record
        }
    }

    fileprivate func prepareICloudLocationsDic(_ locations: [CKRecord]) {
        for record: CKRecord in locations {
            let recordId = record["activityid"] as! Int
            iCloudLocationsDic[recordId] = record
        }
    }

}
