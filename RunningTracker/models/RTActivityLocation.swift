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

    fileprivate(set) var location : CLLocation!
    fileprivate(set) var timestamp : Double = 0
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
        let location = aDecoder.decodeObject(forKey: ActivityLocationPropertyKey.locationKey) as! CLLocation
        let timestamp = aDecoder.decodeDouble(forKey: ActivityLocationPropertyKey.timestampKey)
        let distance = aDecoder.decodeDouble(forKey: ActivityLocationPropertyKey.distanceKey)
        let firstAfterResumed = aDecoder.decodeBool(forKey: ActivityLocationPropertyKey.firstAfterResumedKey)
        self.init(location: location, timestamp:timestamp, firstAfterResumed:firstAfterResumed, distance:distance)
    }

    internal func encode(with aCoder: NSCoder) {
        aCoder.encode(location!, forKey:ActivityLocationPropertyKey.locationKey)
        aCoder.encode(timestamp, forKey:ActivityLocationPropertyKey.timestampKey)
        aCoder.encode(distance, forKey:ActivityLocationPropertyKey.distanceKey)
        aCoder.encode(firstAfterResumed, forKey:ActivityLocationPropertyKey.firstAfterResumedKey)
    }

}
