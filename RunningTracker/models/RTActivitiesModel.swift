//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

enum RTActivitiesError:ErrorType {
    case RTActivityAlreadySet
    case RTActivityNotSet

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
    private(set) var checkMarks = [Int:CLLocation]()

    private(set) var currentActivityPaused : Bool = false
    private(set) var currentActivityJustResumed : Bool = false
    private(set) var activityRunning : Bool = false
    private(set) var currentActivityPausedAt : NSTimeInterval = 0
    private var nextMarker = 1000

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
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:"activitiesSaved", object:nil))
        })

        return true
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
        var success = false
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

        if self.currentActivitiesLocationsLength() > 0 {
            activities.append(self.currentActivity)
            success = true
        }
        activityRunning = false
        currentActivity.activityFinished(NSDate().timeIntervalSince1970)
        currentActivity = nil
        refreshValues()
        return success
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
        return currentActivity.addActivityLocation(activity, checkMarkers: true)
    }

    func getElapsedTime() -> NSTimeInterval {
        var elapsedTime = 0.0
        if let activity = currentActivity {
            elapsedTime = activity.pausedTime + activity.startTime
        }
        return getNow() - elapsedTime
    }

    func getDistanceDone() -> Double {
        return currentActivity.distance
    }

    func getPaceLastKM() -> Double {
        var activityLocations = currentActivity.getActivitiesCopy()

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

    func activitiesLength() -> Int {
        return self.activities.count
    }

    func getActivitiesCopy()->[RTActivity]{
        let copyArray : [RTActivity] = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(activities)) as! [RTActivity]
        return copyArray
    }

    func getCurrentActivityCopy() -> RTActivity? {
        if self.currentActivity == nil {
            guard self.getActivitiesCopy().count > 0 else {
                return nil
            }
            return self.getActivitiesCopy().last!
        }
        let copyActivity : RTActivity = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self.currentActivity)) as! RTActivity
        return copyActivity
    }

    private func currentActivitiesLocationsLength() -> Int {
        if currentActivity == nil {
            return 0
        }
        return self.currentActivity.getActivitiesCopy().count
    }

    func deleteAllActivities(){
        self.activities = [RTActivity]()
    }

    func getNow() -> NSTimeInterval {
        return NSDate().timeIntervalSince1970
    }

}
