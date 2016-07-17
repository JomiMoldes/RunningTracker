//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

enum RTActivitiesError:ErrorType {
    case RTActivityAlreadySet
}

class RTActivitiesModel {

    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("activities")

    private var activities:[RTActivity]!

    private var currentActivity : RTActivity!

    private(set) var currentActivityPaused : Bool = false
    private(set) var currentActivityJustResumed : Bool = false
    private(set) var activityRunning : Bool = false
    private(set) var currentActivityPausedAt : NSTimeInterval = 0
    private(set) var currentActivityPausedTime : NSTimeInterval = 0

    init(){
        self.activities = [RTActivity]()
    }

    func startActivity() throws -> Bool {
        guard currentActivity == nil else {
            print("Trying to start activity before ending previous one")
            throw RTActivitiesError.RTActivityAlreadySet
        }
        self.currentActivity = RTActivity(activities: [RTActivityLocation](), startTime: NSDate().timeIntervalSinceReferenceDate, endTime: nil)
        activityRunning = true
        return true
    }

    func saveActivities(path:String) -> Bool {
        if(self.activities.count == 0){
            return false
        }
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.activities, toFile: path)
        return isSuccessfulSave
    }

    func loadActivities(path:String) {
        self.activities = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [RTActivity]
        if self.activities == nil {
            self.activities = [RTActivity]()
        }
    }

    func endActivity() -> Bool {
        if currentActivity == nil {
            print("Trying to end activity but there is none")
            return false
        }
        activities.append(self.currentActivity)
        activityRunning = false
        currentActivity.endTime(NSDate().timeIntervalSinceReferenceDate)
        currentActivity = nil
        refreshValues()
        return true
    }

    func refreshValues() {
        currentActivityPaused = false
        currentActivityJustResumed = false
        currentActivityPausedTime = 0
        currentActivityPausedAt = 0
    }

    func addActivityLocation(activity:RTActivityLocation){
        if currentActivityPaused || currentActivity == nil {
            return
        }

        if currentActivityJustResumed {
            currentActivityJustResumed = false
            activity.firstAfterResumed = true
        }
        currentActivity.addActivityLocation(activity)
    }

    func getElapsedTime() -> NSTimeInterval {
        return NSDate().timeIntervalSinceReferenceDate - currentActivityPausedTime - currentActivity.startTime
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

        for var i = activityLocations.count - 1; i >= 0; --i{
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

    func isCurrentActivityPaused()->Bool{
        return currentActivityPaused
    }

    func pauseActivity(){
        currentActivityPaused = true
        currentActivityPausedAt = NSDate().timeIntervalSinceReferenceDate
    }

    func resumeActivity(){
        currentActivityPaused = false
        currentActivityPausedTime += NSDate().timeIntervalSinceReferenceDate - currentActivityPausedAt
        currentActivityPausedAt = 0
        currentActivityJustResumed = true
    }
    
    func isCurrentActivityDefined()-> Bool {
        return currentActivity != nil
    }

    func activitiesLenght() -> Int {
        return self.activities.count
    }

    func deleteAllActivities(){
        self.activities = [RTActivity]()
    }

}
