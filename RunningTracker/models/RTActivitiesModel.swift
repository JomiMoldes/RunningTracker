//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit

enum RTActivitiesError:ErrorType {
    case RTActivityAlreadySet
}

class RTActivitiesModel {

    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
#if DEBUG
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("debug_activities")
#else
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("activities")
#endif

    private var activities:[RTActivity]!

    private var currentActivity : RTActivity!

    private(set) var currentActivityPaused : Bool = false
    private(set) var currentActivityJustResumed : Bool = false
    private(set) var activityRunning : Bool = false
    private(set) var currentActivityPausedAt : NSTimeInterval = 0

    init(){
        self.activities = [RTActivity]()
    }

    func startActivity() throws -> Bool {
        guard currentActivity == nil else {
            print("Trying to start activity before ending previous one")
            throw RTActivitiesError.RTActivityAlreadySet
        }
        self.currentActivity = RTActivity(activities: [RTActivityLocation](), startTime: getNow(), finishTime: 0, pausedTime2: 0)
        activityRunning = true
        return true
    }

    func saveActivities(path:String, storeManager:RTStoreActivitiesManager) -> Bool {
        if(self.activities.count == 0){
            return false
        }

        storeManager.saveActivities(self.activities, completion: {
            activities in
            self.activities = activities
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:"activitiesLoaded", object:nil))
        })

        return true
    }

    func saveOnICloud() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let record = CKRecord(recordType: "Activities")
        record.setValue(12333, forKey: "endtime")
        record.setValue(12000, forKey: "starttime")
        record.setValue(10, forKey: "pausedtime")
        record.setValue("12333", forKey: "locationsid")

        privateDatabase.saveRecord(record, completionHandler: {record, error in
            if error != nil {
                print ("there was an error trying to save the activity")
            }else{
                print ("record has been saved")
            }
        })

        print("trying to save in private database")
    }

    func loadActivities(path:String, storeManager:RTStoreActivitiesManager) {
        storeManager.start(path, completion: {
            activities in
            self.activities = activities
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:"activitiesLoaded", object:nil))
        })
        return
    }

    func endActivity() -> Bool {
        if currentActivity == nil {
            print("Trying to end activity but there is none")
            return false
        }

//        if currentActivitesLocationsLenght() == 0 {
//            let now = NSDate().timeIntervalSince1970
//            let location = CLLocation(coordinate:CLLocationCoordinate2DMake(CLLocationDegrees(12.9), CLLocationDegrees(13)), altitude: 10.0, horizontalAccuracy: 5, verticalAccuracy: 50, timestamp: NSDate())
//            let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: now)
//            self.addActivityLocation(activityLocation!)
//        }

        if self.currentActivitesLocationsLenght() > 0 {
            activities.append(self.currentActivity)
        }
        activityRunning = false
        currentActivity.activityFinished(NSDate().timeIntervalSince1970)
        currentActivity = nil
        refreshValues()
        return true
    }

    func refreshValues() {
        currentActivityPaused = false
        currentActivityJustResumed = false
        currentActivityPausedAt = 0
    }

    func addActivityLocation(activity:RTActivityLocation) -> Bool {
        if currentActivityPaused || currentActivity == nil {
            return false
        }

        if currentActivityJustResumed {
            currentActivityJustResumed = false
            activity.firstAfterResumed = true
        }
        return currentActivity.addActivityLocation(activity)
    }

    func getElapsedTime() -> NSTimeInterval {
        return getNow() - getCurrentActivityPausedTime() - currentActivity.startTime
    }

    func getDistanceDone() -> Double {
        return currentActivity.distance
    }

    func getPaceLastKM() -> Double {
        var activityLocations = currentActivity.getActivities()

        guard activityLocations.count > 0 else {
            return 0.00
        }
        var totalDistance:Double = 0
        var startTime:NSTimeInterval = 0
        var endTime:NSTimeInterval = 0
        var totalTime:NSTimeInterval = 0
        var firstActivityLocation:RTActivityLocation?
        let lastActivityLocation:RTActivityLocation = activityLocations[activityLocations.count - 1]

        let maxValue = activityLocations.count - 1
        for i in maxValue.stride(through: 0, by: -1)  {

            firstActivityLocation = activityLocations[i]
            let distance = firstActivityLocation!.distance
            totalDistance += distance
            if totalDistance >= 1000 {
                break
            }
        }

        startTime = firstActivityLocation!.timestamp
        endTime = lastActivityLocation.timestamp
        totalTime = endTime - startTime
        if totalTime <= 0 || totalDistance <= 0 {
            return 0.00
        }

        let pace = 1000 * totalTime / totalDistance
        return pace
    }

    func currentActivityLocations() -> [RTActivityLocation] {
        return self.currentActivity.getActivities()
    }

    func pauseActivity(){
        currentActivityPaused = true
        currentActivityPausedAt = getNow()
    }

    func resumeActivity(){
        currentActivityPaused = false
        currentActivity.pausedTime += getNow() - currentActivityPausedAt
        currentActivityPausedAt = 0
        currentActivityJustResumed = true
    }
    
    func isCurrentActivityDefined()-> Bool {
        return currentActivity != nil
    }

    func activitiesLenght() -> Int {
        return self.activities.count
    }

    func getActivities()->[RTActivity]{
        var copy = [RTActivity]()
        for activity:RTActivity in activities {
            copy.append(activity)
        }
        return copy
    }

    func currentActivitesLocationsLenght() -> Int {
        if currentActivity == nil {
            return 0
        }
        return self.currentActivity.getActivities().count
    }

    func currentActivityStartTime() -> Double {
        if currentActivity == nil {
            return 0
        }
        return self.currentActivity.startTime
    }

    func getCurrentActivityPausedTime() -> Double {
        if currentActivity == nil {
            return 0
        }
        return self.currentActivity.pausedTime
    }

    func deleteAllActivities(){
        self.activities = [RTActivity]()
    }

    func getNow() -> NSTimeInterval {
        return NSDate().timeIntervalSince1970
    }

}
