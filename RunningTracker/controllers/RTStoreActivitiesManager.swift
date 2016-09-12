//
// Created by MIGUEL MOLDES on 1/8/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

class RTStoreActivitiesManager {

    var allActivitiesRecords = [CKRecord]()
    var allLocationsRecords = [CKRecord]()
    var activitiesSavedLocally : [RTActivity]?
    var completion : (([RTActivity]) -> Void)?
    var localPath : String?
    var activitiesToSave : [RTActivity]?
    var fetchingFromICloudSucceeded : Bool = true
    var recordFetched = 0

    func start(path:String, completion:([RTActivity])->Void) -> Bool {
        self.completion = completion
        self.localPath = path
        startSync()
        return true
    }

    func saveActivities(activities:[RTActivity], completion:([RTActivity])->Void) {
        self.completion = completion
        self.activitiesSavedLocally = activities
        self.saveLocally()
        self.saveActivityOnICloud(activities[activities.count - 1])
    }

    func deleteActivity(activity:RTActivity) {
        for localActivity:RTActivity in self.activitiesSavedLocally! {
            if Int(localActivity.startTime) == Int(activity.startTime) {
                let index = self.activitiesSavedLocally!.indexOf(localActivity)
                self.activitiesSavedLocally!.removeAtIndex(index!)
                saveLocally()
            }
        }

        var recordsToDelete : [CKRecord] = [CKRecord]()
        let activityId = Int(activity.startTime)
        for record : CKRecord in self.allActivitiesRecords {
            let recordId = record.valueForKey("starttime") as! Int
            if  recordId == activityId {
                recordsToDelete.append(record)
                break
            }
        }

        for location : CKRecord in self.allLocationsRecords {
            let recordId = location.valueForKey("activityid") as! Int
            if recordId == activityId {
                recordsToDelete.append(location)
            }
        }

        deleteAll(recordsToDelete)
    }

    private func saveActivityOnICloud(activity:RTActivity) {
        var recordsToAdd = [CKRecord]()
        let activityId = Int(activity.startTime)
        let newRecord = self.createRecordByActivity(activity)
        recordsToAdd.append(newRecord)
        recordsToAdd += self.getLocationRecords(activity.getActivitiesCopy(), activityId:activityId)
        self.saveRecords(recordsToAdd, completion:{
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.startSync()
            }
        })
    }

    private func startSync(){
        self.allActivitiesRecords = [CKRecord]()
        self.allLocationsRecords = [CKRecord]()
        self.fetchingFromICloudSucceeded = true

        /*if  true {
//            fetchActivitiesFromICloud()
            self.fetchLocations()
               return
        } */
        fetchActivitiesLocal()
        fetchActivitiesFromICloud()
    }

    private func fetchFromICloudDone() {
        /*if  true {
            self.deleteAll(self.allLocationsRecords)
            self.deleteAll(self.allActivitiesRecords)
            return
        } */

        syncLocalAndICloudData()
    }

    private func syncLocalAndICloudData() {
        syncAndSaveLocally()
        syncAndSaveICloud()
    }

    private func synchronisationDone() {
        self.completion!(self.activitiesSavedLocally!)
    }

    private func syncAndSaveLocally() {
        for activityRecord in self.allActivitiesRecords {
            let activityId = activityRecord["starttime"] as! Int
            if !activityAlreadySavedLocally(activityId) {

                let activityLocations = self.getLocationsForActivityRecord(activityId)
                let activity = RTActivity(activities:activityLocations,
                        startTime: activityRecord["starttime"] as! Double,
                        finishTime: activityRecord["endtime"] as! Double,
                        pausedTime2: activityRecord["pausedtime"] as! Double)
                self.activitiesSavedLocally!.append(activity!)
            }
        }
        saveLocally()
    }

    private func syncAndSaveICloud() {
        if !self.fetchingFromICloudSucceeded {
            self.synchronisationDone()
            return
        }
        var recordsToAdd = [CKRecord]()
        for activity:RTActivity in self.activitiesSavedLocally! {
            let activityId = Int(activity.startTime)
            if !activityAlreadySavedOnICloud(activityId) {
                let newRecord = self.createRecordByActivity(activity)
                recordsToAdd.append(newRecord)
                recordsToAdd += self.getLocationRecords(activity.getActivitiesCopy(), activityId:activityId)
            }
        }
        if recordsToAdd.count > 0 {
            self.saveRecords(recordsToAdd, completion:{
                self.synchronisationDone()
            })
        }else {
            self.synchronisationDone()
        }
    }

    private func activityAlreadySavedLocally(id:Int) -> Bool {
        for activity:RTActivity in self.activitiesSavedLocally! {
            if Int(activity.startTime) == id {
                return true
            }
        }
        return false
    }

    private func activityAlreadySavedOnICloud(id:Int) -> Bool {
        for activity:CKRecord in self.allActivitiesRecords {
            let recordId = activity["starttime"] as! Int
            if recordId == id {
                return true
            }
        }
        return false
    }

    private func getLocationsForActivityRecord(activityId:Int) -> [RTActivityLocation] {
        var locations = [RTActivityLocation]()
        for locationRecord in self.allLocationsRecords {
            let recordId = locationRecord["activityid"] as! Int
            if recordId == activityId {
                let firstAfterResumed : Bool = locationRecord["firstafterresumed"] as! Bool
                let locationActivity = RTActivityLocation(location: locationRecord["location"] as! CLLocation, timestamp: locationRecord["timestamp"] as! Double, firstAfterResumed: firstAfterResumed)
                locations.append(locationActivity!)
            }
        }
        return locations
    }

    private func fetchActivitiesFromICloud() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let query = CKQuery(recordType: "Activities", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))

        let queryOperation = CKQueryOperation(query: query)

        queryOperation.recordFetchedBlock = fetchedActivitiesRecord
        queryOperation.qualityOfService = .UserInitiated
        queryOperation.queryCompletionBlock = { [weak self] (cursor: CKQueryCursor?, error: NSError?) in
            if error != nil {
                print(error)
                self!.fetchingFromICloudSucceeded = false
                self!.fetchFromICloudDone()
                return
            }
            if cursor != nil {
                self!.fetchRecordsWithCursor(cursor!, recordBlock:self!.fetchedActivitiesRecord, completionBlock: self!.fetchLocations)
            } else if self!.allActivitiesRecords.count > 0 {
                self!.fetchLocations()
            } else {
                self!.fetchFromICloudDone()
            }
        }

        privateDatabase.addOperation(queryOperation)
    }

    private func fetchLocations() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let query = CKQuery(recordType: "Locations", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))

        let queryOperation = CKQueryOperation(query: query)

        queryOperation.recordFetchedBlock = fetchedLocationsRecord
        queryOperation.qualityOfService = .UserInitiated
        queryOperation.queryCompletionBlock = { [weak self] (cursor: CKQueryCursor?, error: NSError?) in
            if error != nil {
                print(error)
                self!.fetchingFromICloudSucceeded = false
                self!.fetchFromICloudDone()
                return
            }
            if cursor != nil {
                self!.fetchRecordsWithCursor(cursor!, recordBlock:self!.fetchedLocationsRecord, completionBlock: self!.fetchFromICloudDone)
            } else {
                self!.fetchFromICloudDone()
            }
        }

        privateDatabase.addOperation(queryOperation)
    }

    func fetchedActivitiesRecord(record: CKRecord!) {
        recordFetched = recordFetched + 1
        print("\(NSDate().timeIntervalSinceReferenceDate*1000) \(recordFetched)")
        self.allActivitiesRecords.append(record)
    }

    func fetchedLocationsRecord(record: CKRecord!) {
        recordFetched = recordFetched + 1
        print("\(NSDate().timeIntervalSinceReferenceDate*1000) \(recordFetched)")
        self.allLocationsRecords.append(record)
    }

    private func fetchRecordsWithCursor(cursor:CKQueryCursor, recordBlock:(CKRecord) -> Void, completionBlock:()->Void){
        let database = CKContainer.defaultContainer().privateCloudDatabase
        let queryOperation = CKQueryOperation(cursor: cursor)
        queryOperation.qualityOfService = .UserInitiated
        queryOperation.recordFetchedBlock = recordBlock

        queryOperation.queryCompletionBlock = { cursor, error in

            if cursor != nil {
                self.fetchRecordsWithCursor(cursor!, recordBlock: recordBlock, completionBlock: completionBlock)
            } else {
                completionBlock()
            }
        }

        database.addOperation(queryOperation)
    }

    private func fetchActivitiesLocal() {
        var activities = NSKeyedUnarchiver.unarchiveObjectWithFile(self.localPath!) as? [RTActivity]
        if activities == nil {
            activities = [RTActivity]()
        }
        self.activitiesSavedLocally = activities
    }

    private func getLocationRecords(locations:[RTActivityLocation], activityId:Int) -> [CKRecord] {
        var locationRecords = [CKRecord]()
        for location in locations {
            let record = CKRecord(recordType: "Locations")
            record.setValue(activityId, forKey: "activityid")
            record.setValue(location.firstAfterResumed, forKey: "firstafterresumed")
            record.setValue(location.location, forKey: "location")
            record.setValue(Int(location.timestamp), forKey: "timestamp")
            locationRecords.append(record)
        }
        return locationRecords
    }

    private func saveLocally() -> Bool {
        let isSuccessfulSaved = NSKeyedArchiver.archiveRootObject(self.activitiesSavedLocally!, toFile: self.localPath!)
        return isSuccessfulSaved
    }

    private func createRecordByActivity(activity:RTActivity) -> CKRecord {
        let record = CKRecord(recordType: "Activities")
        record.setValue(Int(activity.startTime), forKey: "starttime")
        record.setValue(Int(activity.finishTime), forKey: "endtime")
        record.setValue(Int(activity.pausedTime), forKey: "pausedtime")
        return record
    }

    private func deleteAll(records:[CKRecord]){
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase

        for record in records {
            privateDatabase.deleteRecordWithID(record.recordID, completionHandler: {
                record, error in
            })
        }
    }

    private func saveRecords(records:[CKRecord], completion:()->Void) {
        let saveOperation = RTSaveRecordsOperation()
        saveOperation.saveRecord(records, completion: completion)
    }

}
