//
// Created by MIGUEL MOLDES on 18/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit

class RTActivitiesAndRecordsHelper {

    func getRecordFromRecordsListByActivityId(_ activityId:Int, records:[CKRecord]) -> CKRecord {
        for record in records {
            let recordId = record.value(forKey: "starttime") as! Int
            if  recordId == activityId {
                return record
            }
        }
        return CKRecord(recordType:"FakeActivity")
    }

    func createRecordByActivity(_ activity: RTActivity) -> CKRecord {
        let record = CKRecord(recordType: "Activities2")
        record.setValue(Int(activity.startTime), forKey: "starttime")
        record.setValue(Int(activity.finishTime), forKey: "endtime")
        record.setValue(Int(activity.pausedTime), forKey: "pausedtime")
        record.setValue(Int(activity.distance), forKey: "distance")
        return record
    }

    func createLocationRecords(_ activity: RTActivity) -> [CKRecord] {
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

    func createRecordsForActivity(_ activity:RTActivity) -> [CKRecord] {
        var records = [CKRecord]()
        records.append(createRecordByActivity(activity))
        records += createLocationRecords(activity)
        return records
    }



}
