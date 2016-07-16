//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

class RTActivity {

    private var activities = [RTActivityLocation]()
    var startTime : Double = 0
    private var endTime : Double = 0
    var distance : Double = 0

    func addActivityLocation(activity:RTActivityLocation, withDistance:Bool = true){
        var lastActivityLocation:RTActivityLocation?;
        if activities.count > 0 {
            lastActivityLocation = activities[activities.count - 1]
            if lastActivityLocation != nil{
                let coords = lastActivityLocation!.location.coordinate
                if coords.latitude == activity.location.coordinate.latitude && coords.longitude == activity.location.coordinate.longitude {
                    return
                }
            }
        }

        activities.append(activity)
        if lastActivityLocation != nil && withDistance {
            let distanceDone = activity.location.distanceFromLocation(lastActivityLocation!.location)
            distance += distanceDone
            activity.distance = distanceDone
        }

    }

    func endTime(time:NSTimeInterval){
        self.endTime = time;
    }

    func getActivities()->[RTActivityLocation]{
        var copy = [RTActivityLocation]()
        for activity:RTActivityLocation in activities {
            copy.append(activity)
        }
        return copy

    }

}
