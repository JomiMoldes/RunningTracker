//
// Created by MIGUEL MOLDES on 18/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit

class RTActivitiesAndRecordsHelper {

    func createRecordByActivity(activity: RTActivity) -> CKRecord {
        let record = CKRecord(recordType: "Activities2")
        record.setValue(Int(activity.startTime), forKey: "starttime")
        record.setValue(Int(activity.finishTime), forKey: "endtime")
        record.setValue(Int(activity.pausedTime), forKey: "pausedtime")
        record.setValue(Int(activity.distance), forKey: "distance")
        return record
    }

    func createLocationRecords(activity: RTActivity) -> [CKRecord] {
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

    func createRecordsForActivity(activity:RTActivity) -> [CKRecord] {
        var records = [CKRecord]()
        records.append(createRecordByActivity(activity))
        records += createLocationRecords(activity)
        return records
    }



}
