//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

class RTActivitiesModel {

    static let sharedInstance = RTActivitiesModel()

    private var currentActivity : RTActivity!

    private var currentActivityPaused : Bool = false
    private var currentActivityJustResumed : Bool = false
    private var currentActivityPausedAt : NSTimeInterval = 0
    private var currentActivityPausedTime : NSTimeInterval = 0

    private init(){}

    func startActivity(){
        if currentActivity != nil {
            print("Trying to start activity before ending previous one")
            return
        }
        currentActivity = RTActivity()
        currentActivity.startTime = NSDate().timeIntervalSinceReferenceDate
    }

    func endActivity(){
        if currentActivity == nil {
            print("Trying to end activity but there is none")
            return
        }
        currentActivity.endTime(NSDate().timeIntervalSinceReferenceDate)
    }

    func addActivityLocation(activity:RTActivityLocation){
        if currentActivity == nil {
            currentActivity = RTActivity()
        }
        if currentActivityPaused {
            return
        }

        var withDistance:Bool = true
        if currentActivityJustResumed {
            withDistance = false
            currentActivityJustResumed = false
        }
        currentActivity.addActivityLocation(activity, withDistance: withDistance)
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

}
