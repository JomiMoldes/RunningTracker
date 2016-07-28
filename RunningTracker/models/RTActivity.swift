//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

struct ActivityPropertyKey{
    static let locationsKey = "locations"
    static let startTimeKey = "startTime"
    static let endTimeKey = "endTime"
    static let pausedTimeKey = "pausedTime"
}

class RTActivity:NSObject , NSCoding {

    private var activities = [RTActivityLocation]()
    var startTime : Double = 0
    var pausedTime : Double = 0
    private(set) var finishTime : Double = 0
    var distance : Double = 0

    init?(activities:[RTActivityLocation], startTime:Double, finishTime:Double, pausedTime2:Double){
        self.startTime = startTime
        self.finishTime = finishTime
        self.pausedTime = pausedTime2
        super.init()
        for i in 0..<activities.count {
            let activityLocation = activities[i]
            addActivityLocation(activityLocation)
        }
    }

    func addActivityLocation(activityLocation:RTActivityLocation) -> Bool{

        if activityLocation.location.horizontalAccuracy > 20 {
            return false
        }

        var lastActivityLocation:RTActivityLocation?
        if activities.count > 0 {
            lastActivityLocation = activities[activities.count - 1]

            if lastActivityLocation != nil{
                let coords = lastActivityLocation!.location.coordinate
                if coords.latitude == activityLocation.location.coordinate.latitude && coords.longitude == activityLocation.location.coordinate.longitude {
                    return false
                }
            }
        }

        activities.append(activityLocation)
        if lastActivityLocation != nil && !activityLocation.firstAfterResumed {
            let distanceDone = activityLocation.location.distanceFromLocation(lastActivityLocation!.location)
            distance += distanceDone

            activityLocation.distance = distanceDone
        }
        return true
    }

    func activityFinished(time:NSTimeInterval){
        self.finishTime = time
    }

    func getActivities()->[RTActivityLocation]{
        var copy = [RTActivityLocation]()
        for activity:RTActivityLocation in activities {
            copy.append(activity)
        }
        return copy
    }

    func getDuration() -> Double {
        return self.finishTime - self.pausedTime - self.startTime
    }

    func getPace() -> Double {
        let totalTime = self.finishTime - startTime
        if totalTime <= 0 || distance <= 0 {
            return 0.00
        }

        let pace = 1000 * totalTime / distance
        return pace
    }

// MARK NSCoding

    internal func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeDouble(startTime, forKey:ActivityPropertyKey.startTimeKey)
        aCoder.encodeDouble(finishTime, forKey:ActivityPropertyKey.endTimeKey)
        aCoder.encodeDouble(pausedTime, forKey:ActivityPropertyKey.pausedTimeKey)
        aCoder.encodeObject(activities, forKey:ActivityPropertyKey.locationsKey)
    }

    required convenience init?(coder aDecoder: NSCoder){
        let activities = aDecoder.decodeObjectForKey(ActivityPropertyKey.locationsKey) as! [RTActivityLocation]
        let startTime = aDecoder.decodeDoubleForKey(ActivityPropertyKey.startTimeKey)
        let endTime = aDecoder.decodeDoubleForKey(ActivityPropertyKey.endTimeKey)
        let pausedTime = aDecoder.decodeDoubleForKey(ActivityPropertyKey.pausedTimeKey)
        self.init(activities: activities, startTime:startTime, finishTime:endTime, pausedTime2: pausedTime)
    }

}
