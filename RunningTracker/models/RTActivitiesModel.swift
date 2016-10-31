//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation
import PromiseKit

enum RTActivitiesError:Error {
    case rtActivityAlreadySet
    case rtActivityNotSet

}

class RTActivitiesModel {

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
#if DEBUG
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("debug_activities")
#else
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("activities")
#endif

    fileprivate var activities:[RTActivity]!

    fileprivate var currentActivity : RTActivity!
    fileprivate(set) var checkMarks = [Int:CLLocation]()

    fileprivate(set) var currentActivityPaused : Bool = false
    fileprivate(set) var currentActivityJustResumed : Bool = false
    fileprivate(set) var activityRunning : Bool = false
    fileprivate(set) var currentActivityPausedAt : TimeInterval = 0
    fileprivate var nextMarker = 1000

    init(){
        self.activities = [RTActivity]()
    }

    func startActivity() throws {
        guard currentActivity == nil else {
            print("Trying to start activity before ending previous one")
            throw RTActivitiesError.rtActivityAlreadySet
        }
//        self.currentActivity = RTActivity(activities: [RTActivityLocation](), startTime: getNow(), finishTime: 0, pausedTime2: 0, distance: 0, locationsAfterResumed: [CLLocation]())
        self.currentActivity = RTActivity(startTime:getNow())
        activityRunning = true
    }

    func saveActivities(_ path:String, storeManager: RTStoreActivitiesManager) -> Bool {
        if(self.activities.count == 0){
            return false
        }

        storeManager.saveActivities(self.activities, path:path).then {
            activities -> Void in
            self.activities = activities
            let notificationName = NSNotification.Name(rawValue:"activitiesSaved")
            
            NotificationCenter.default.post(name:notificationName, object:nil)
        }.catch(policy:.allErrors){
            error in
            print(error)
            let notificationSavedName = NSNotification.Name(rawValue: "activitiesSaved")
            NotificationCenter.default.post(name:notificationSavedName, object:nil)
        }

        return true
    }

    func deleteActivity(_ activityToDelete:RTActivity, storeManager: RTStoreActivitiesManager) {
        let notificationName = NSNotification.Name(rawValue: "activityDeleted")
        for activity:RTActivity in self.activities {
            if activity.startTime == activityToDelete.startTime {
                storeManager.deleteActivity(activityToDelete, path:RTActivitiesModel.ArchiveURL.path).then {
                    success -> Void in
                    NotificationCenter.default.post(name:notificationName, object:nil)

                }.catch(policy:.allErrors){
                    error in
                    print(error)
                    NotificationCenter.default.post(name:notificationName, object:nil)
                }
                self.activities.remove(at: self.activities.index(of: activity)!)
                return
            }
        }

    }

    func loadActivities(_ path:String, storeManager: RTStoreActivitiesManager) {
        storeManager.loadActivities(path).then {
            activities -> Void in
            self.activities = activities
            let notificationName = NSNotification.Name(rawValue: "activitiesLoaded")
            NotificationCenter.default.post(name:notificationName, object:nil)
        }.catch(policy:.allErrors){
            error in
            print(error)
        }
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

        if self.currentActivitiesLocationsLength() > 1 {
            activities.append(self.currentActivity)
            success = true
        }
        activityRunning = false
        currentActivity.activityFinished(getNow())
        currentActivity = nil
        refreshValues()
        return success
    }

    func refreshValues() {
        currentActivityPaused = false
        currentActivityJustResumed = false
        currentActivityPausedAt = 0
    }

    func addActivityLocation(_ activity:RTActivityLocation) -> Bool {
        if currentActivityPaused || currentActivity == nil {
            return false
        }

        if currentActivityJustResumed {
            currentActivityJustResumed = false
            activity.firstAfterResumed = true
        }
        return currentActivity.addActivityLocation(activity, checkMarkers: true)
    }

    func getElapsedTime() -> TimeInterval {
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
        var startTime:TimeInterval = 0
        var endTime:TimeInterval = 0
        var totalTime:TimeInterval = 0
        var firstActivityLocation:RTActivityLocation?
        let lastActivityLocation:RTActivityLocation = activityLocations[activityLocations.count - 1]

        let maxValue = activityLocations.count - 1
        for i in stride(from: maxValue, through: 0, by: -1)  {

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
        let copyArray : [RTActivity] = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: activities)) as! [RTActivity]
        return copyArray
    }

    func getCurrentActivityCopy() -> RTActivity? {
        if self.currentActivity == nil {
            guard self.getActivitiesCopy().count > 0 else {
                return nil
            }
            return self.getActivitiesCopy().last!
        }
        let copyActivity : RTActivity = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self.currentActivity)) as! RTActivity
        return copyActivity
    }

    fileprivate func currentActivitiesLocationsLength() -> Int {
        if currentActivity == nil {
            return 0
        }
        return self.currentActivity.getActivitiesCopy().count
    }

    func deleteAllActivities(){
        self.activities = [RTActivity]()
    }

    func getNow() -> TimeInterval {
        return Date().timeIntervalSince1970
    }

    func getBestPace() -> Double {
        var bestPace = 0.0
        for activity : RTActivity in activities {
            let pace = activity.getPace()
            bestPace = (bestPace == 0.0) ? pace : bestPace
            bestPace = (pace < bestPace) ? pace : bestPace
        }
        return bestPace
    }

    func getLongestDistance() -> Double {
        var longest = 0.0
        for activity : RTActivity in activities {
            let distance = activity.distance
            longest = (distance > longest) ? distance : longest
        }
        return longest
    }

}
