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

    private func saveActivityOnICloud(activity:RTActivity) {
        var recordsToAdd = [CKRecord]()
        let activityId = Int(activity.startTime)
        let newRecord = self.createRecordByActivity(activity)
        recordsToAdd.append(newRecord)
        recordsToAdd += self.getLocationRecords(activity.getActivities(), activityId:activityId)
        self.saveRecords(recordsToAdd, completion:{
            self.startSync()
        })
    }

    private func startSync(){
        self.allActivitiesRecords = [CKRecord]()
        self.allLocationsRecords = [CKRecord]()
        self.fetchingFromICloudSucceeded = true
        fetchActivitiesLocal()
        fetchActivitiesFromICloud()
    }

    private func fetchFromICloudDone() {
        syncLocalAndICloudData()
    }

    private func syncLocalAndICloudData() {
        syncAndSaveLocally()
        syncAndSaveICloud()
    }

    func synchronisationDone() {
        self.completion!(self.activitiesSavedLocally!)
    }




    func syncAndSaveLocally() {
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
                recordsToAdd += self.getLocationRecords(activity.getActivities(), activityId:activityId)
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

    func activityAlreadySavedLocally(id:Int) -> Bool {
        for activity:RTActivity in self.activitiesSavedLocally! {
            if Int(activity.startTime) == id {
                return true
            }
        }
        return false
    }

    func activityAlreadySavedOnICloud(id:Int) -> Bool {
        for activity:CKRecord in self.allActivitiesRecords {
            let recordId = activity["starttime"] as! Int
            if recordId == id {
                return true
            }
        }
        return false
    }

    func getLocationsForActivityRecord(activityId:Int) -> [RTActivityLocation] {
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
        privateDatabase.performQuery(query, inZoneWithID: nil, completionHandler: {
            records, error in
            if error != nil {
                print(error)
                self.fetchingFromICloudSucceeded = false
                self.fetchFromICloudDone()
                return
            }

            if records != nil && records!.count > 0 {
                self.allActivitiesRecords = records!
                self.fetchLocations()
            }else {
                self.fetchingFromICloudSucceeded = false
                self.fetchFromICloudDone()
            }
        })
    }

    private func fetchLocations() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let query = CKQuery(recordType: "Locations", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))

        privateDatabase.performQuery(query, inZoneWithID: nil, completionHandler: {
            records, error in

            if error != nil || records == nil {
                self.fetchingFromICloudSucceeded = false
                self.fetchFromICloudDone()
                return
            }

            if  records != nil {
                self.allLocationsRecords = records!
            }else {
                self.fetchingFromICloudSucceeded = false
            }
            self.fetchFromICloudDone()
        })
    }

    private func fetchActivitiesLocal() {
        var activities = NSKeyedUnarchiver.unarchiveObjectWithFile(self.localPath!) as? [RTActivity]
        if activities == nil {
            activities = [RTActivity]()
        }
        self.activitiesSavedLocally = activities
    }

    func getLocationRecords(locations:[RTActivityLocation], activityId:Int) -> [CKRecord] {
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

    func saveLocally() -> Bool {
        let isSuccessfulSaved = NSKeyedArchiver.archiveRootObject(self.activitiesSavedLocally!, toFile: self.localPath!)
        return isSuccessfulSaved
    }

    func createRecordByActivity(activity:RTActivity) -> CKRecord {
        let record = CKRecord(recordType: "Activities")
        record.setValue(Int(activity.startTime), forKey: "starttime")
        record.setValue(Int(activity.finishTime), forKey: "endtime")
        record.setValue(Int(activity.pausedTime), forKey: "pausedtime")
        return record
    }

    private func saveRecords(records:[CKRecord], completion:()->Void) {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase

        let uploadOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)

        uploadOperation.atomic = false
        uploadOperation.database = privateDatabase

        uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: NSError?) -> Void in
//            self.synchronisationDone()
            completion()
        }

        NSOperationQueue().addOperation(uploadOperation)
    }

}