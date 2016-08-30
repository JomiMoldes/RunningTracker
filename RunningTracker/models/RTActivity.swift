//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

struct ActivityPropertyKey{
    static let locationsKey = "locations"
    static let startTimeKey = "startTime"
    static let endTimeKey = "endTime"
    static let pausedTimeKey = "pausedTime"
}

class RTActivity:NSObject , NSCoding {

    private(set) var activities = [RTActivityLocation]()
    var startTime : Double = 0
    var pausedTime : Double = 0
    private(set) var finishTime : Double = 0
    var distance : Double = 0
    private(set) var checkMarks = [Int:CLLocation]()
    private var nextMarker = 1000

    init?(activities:[RTActivityLocation], startTime:Double, finishTime:Double, pausedTime2:Double){
        self.startTime = startTime
        self.finishTime = finishTime
        self.pausedTime = pausedTime2
        super.init()
        for i in 0..<activities.count {
            let activityLocation = activities[i]
            addActivityLocation(activityLocation, checkMarkers:false)
        }
    }

    func addActivityLocation(activityLocation:RTActivityLocation, checkMarkers:Bool) -> Bool{

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
        self.checkMarkers(checkMarkers)
        return true
    }

    private func checkMarkers(drawLastMarker:Bool) {
        var location : CLLocation!
        var index : Int = -1
        let activitiesLocations = activities

        if activitiesLocations.count == 1 {
            location = activitiesLocations[0].location
            index = 0
        }
        if Int(distance) >= nextMarker {
            location = activitiesLocations.last!.location
            index = Int(nextMarker / 1000)
            nextMarker = nextMarker + 1000
        }
        if index > -1 {
            checkMarks[index] = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if drawLastMarker {
                self.drawMarker(["location": location, "km":index])
            }
        }
    }

    private func drawMarker(userInfo:[NSObject:AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName("addKMMarker", object: nil, userInfo: userInfo)
    }

    func activityFinished(time:NSTimeInterval){
        self.finishTime = time
    }

    func getActivitiesCopy()->[RTActivityLocation]{
        var copyList = [RTActivityLocation]()
        for activity:RTActivityLocation in activities {
            let copyActivity : RTActivityLocation = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(activity)) as! RTActivityLocation
            copyList.append(copyActivity)
        }
        return copyList
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

    /*func getActivityId() -> Int {
        if self.activities.count == 0 {

            let now = NSDate().timeIntervalSince1970
            let location = CLLocation(coordinate:CLLocationCoordinate2DMake(CLLocationDegrees(12.55560), CLLocationDegrees(13)), altitude: 10.0, horizontalAccuracy: 5, verticalAccuracy: 50, timestamp: NSDate())
            let activityLocation : RTActivityLocation? = RTActivityLocation(location: location, timestamp: now)
            self.addActivityLocation(activityLocation!)
        }
        let location = self.activities[0].location
        let long = Int(location.coordinate.longitude)
        let lat = Int(location.coordinate.latitude)

        let activityId = Int(String(format: "%d%d%d", Int(self.startTime), long, lat))
        return activityId!
    }   */


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
