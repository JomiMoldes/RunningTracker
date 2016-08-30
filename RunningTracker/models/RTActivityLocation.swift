//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

struct ActivityLocationPropertyKey{
    static let locationKey = "location"
    static let timestampKey = "timestamp"
    static let firstAfterResumedKey = "firstAfterResumed"
    static let distanceKey = "distance"
}

class RTActivityLocation:NSObject , NSCoding {

    private(set) var location : CLLocation!
    private(set) var timestamp : Double = 0
    var distance : Double = 0
    var firstAfterResumed : Bool = false

    init?(location: CLLocation, timestamp: Double, firstAfterResumed:Bool = false, distance:Double = 0.0){
        self.location = location
        self.timestamp = timestamp
        self.firstAfterResumed = firstAfterResumed
        self.distance = distance
        super.init()
    }

//MARK NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey(ActivityLocationPropertyKey.locationKey) as! CLLocation
        let timestamp = aDecoder.decodeDoubleForKey(ActivityLocationPropertyKey.timestampKey)
        let distance = aDecoder.decodeDoubleForKey(ActivityLocationPropertyKey.distanceKey)
        let firstAfterResumed = aDecoder.decodeBoolForKey(ActivityLocationPropertyKey.firstAfterResumedKey)
        self.init(location: location, timestamp:timestamp, firstAfterResumed:firstAfterResumed, distance:distance)
    }

    internal func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location!, forKey:ActivityLocationPropertyKey.locationKey)
        aCoder.encodeDouble(timestamp, forKey:ActivityLocationPropertyKey.timestampKey)
        aCoder.encodeDouble(distance, forKey:ActivityLocationPropertyKey.distanceKey)
        aCoder.encodeBool(firstAfterResumed, forKey:ActivityLocationPropertyKey.firstAfterResumedKey)
    }

}
