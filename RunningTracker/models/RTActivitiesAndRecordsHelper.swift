//
// Created by MIGUEL MOLDES on 18/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit

struct RecordProperty {
    static let startTime = "starttime"
    static let endTime = "endtime"
    static let pausedTime = "pausedtime"
    static let distance = "distance"
    static let activityId = "activityid"
    static let locationsList = "locationslist"
    static let locationsAfterResumed = "locationsafterresumed"
    static let activitiesTableName = "Activities2"
    static let locationsTableName = "Locations2"
    static let fakeActivityTableName = "FakeActivity"
    static let location = "location"
    static let timestamp = "timestamp"
    static let firstAfterResumed = "firstAfterResumed"
}

class RTActivitiesAndRecordsHelper {

    func getRecordFromRecordsListByActivityId(_ activityId:Int, records:[CKRecord]) -> CKRecord {
        for record in records {
            let recordId = record.value(forKey: RecordProperty.startTime) as! Int
            if  recordId == activityId {
                return record
            }
        }
        return CKRecord(recordType:RecordProperty.fakeActivityTableName)
    }

    func createRecordByActivity(_ activity: RTActivity) -> CKRecord {
        let record = CKRecord(recordType: RecordProperty.activitiesTableName)
        record.setValue(Int(activity.startTime), forKey: RecordProperty.startTime)
        record.setValue(Int(activity.finishTime), forKey: RecordProperty.endTime)
        record.setValue(Int(activity.pausedTime), forKey: RecordProperty.pausedTime)
        record.setValue(Int(activity.distance), forKey: RecordProperty.distance)
        return record
    }

    func createLocationRecords(_ activity: RTActivity) -> [CKRecord] {
        let activityId = Int(activity.startTime)
        let locations: [RTActivityLocation] = activity.getActivitiesCopy()
        var locationRecords = [CKRecord]()
        let record = CKRecord(recordType: RecordProperty.locationsTableName)
        record.setValue(activityId, forKey: RecordProperty.activityId)

        let locationsAfterResumed = activity.locationsAfterResumed
        var locationsList = [CLLocation]()
        for location in locations {
            locationsList.append(location.location)
        }
        record.setValue(locationsList, forKey: RecordProperty.locationsList)
        record.setValue(locationsAfterResumed, forKey: RecordProperty.locationsAfterResumed)
        locationRecords.append(record)
        return locationRecords
    }

    func createRecordsForActivity(_ activity:RTActivity) -> [CKRecord] {
        var records = [CKRecord]()
        records.append(createRecordByActivity(activity))
        records += createLocationRecords(activity)
        return records
    }



}
