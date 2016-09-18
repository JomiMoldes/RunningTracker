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

    func execute(localActivities: [RTActivity], iCloudActivities: [CKRecord], path: String) -> Promise<[RTActivity]> {
        savedLocalActivities = localActivities
        prepareLocalActivitiesDic(localActivities)
        prepareICloudActivitiesDic(iCloudActivities)
        self.path = path

        return Promise {
            fulfill, reject in

            var recordsMissingLocally = self.getRecordsMissingLocally(iCloudActivities)
            let recordsToAddOnICloud = [CKRecord]()

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
            }.error(policy: .AllErrors) {
                error in

                print(error)
                reject(error)
            }
        }
    }

    private func saveDifferencesLocally(activitiesRecordsIds: [Int]) -> Bool {
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

        return saveLocally(self.savedLocalActivities)
    }

    private func saveLocally(localActivities: [RTActivity]) -> Bool {
        return NSKeyedArchiver.archiveRootObject(localActivities, toFile: path)
    }

    private func getRecordsMissingOnICloud(localActivities: [RTActivity], iCloudActivities: [CKRecord]) -> [CKRecord] {
        var recordsToAdd = [CKRecord]()
        for activity: RTActivity in localActivities {
            let activityId = Int(activity.startTime)
            if iCloudActivitiesDic[activityId] == nil {
                let newRecord = self.createRecordByActivity(activity)
                recordsToAdd.append(newRecord)
                recordsToAdd += self.createLocationRecords(activity)
            }
        }
        return recordsToAdd
    }

    private func getRecordsMissingLocally(iCloudActivities: [CKRecord]) -> [Int] {
        var recordsIds = [Int]()

        for activityRecord in iCloudActivities {
            let recordId = activityRecord.valueForKey("starttime") as! Int
            if localActivitiesDic[recordId] == nil {
                recordsIds.append(recordId)
            }
        }

        return recordsIds
    }

    private func createRecordByActivity(activity: RTActivity) -> CKRecord {
        let record = CKRecord(recordType: "Activities2")
        record.setValue(Int(activity.startTime), forKey: "starttime")
        record.setValue(Int(activity.finishTime), forKey: "endtime")
        record.setValue(Int(activity.pausedTime), forKey: "pausedtime")
        record.setValue(Int(activity.distance), forKey: "distance")
        return record
    }

    private func createLocationRecords(activity: RTActivity) -> [CKRecord] {
        let activityId = Int(activity.startTime)
        let locations: [RTActivityLocation] = activity.getActivitiesCopy()
        var locationRecords = [CKRecord]()
        let record = CKRecord(recordType: "Locations2")
        record.setValue(activityId, forKey: "activityid")

        let locationsAfterResumed = activity.locationsAfterResumed
        var locationsList = [CLLocation]()
        for location in locations {
            locationsList.append(location.location)
        }
        record.setValue(locationsList, forKey: "locationslist")
        record.setValue(locationsAfterResumed, forKey: "locationsafterresumed")
        locationRecords.append(record)
        return locationRecords
    }

    private func getLocationsLists(activityId: Int) -> (activities:[RTActivityLocation], afterLocations:[CLLocation]) {
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

    private func prepareLocalActivitiesDic(localActivities: [RTActivity]) {
        for activity: RTActivity in localActivities {
            let activityId = Int(activity.startTime)
            localActivitiesDic[activityId] = activity
        }
    }

    private func prepareICloudActivitiesDic(activities: [CKRecord]) {
        for record in activities {
            let recordId = record["starttime"] as! Int
            iCloudActivitiesDic[recordId] = record
        }
    }

    private func prepareICloudLocationsDic(locations: [CKRecord]) {
        for record: CKRecord in locations {
            let recordId = record["activityid"] as! Int
            iCloudLocationsDic[recordId] = record
        }
    }

}
